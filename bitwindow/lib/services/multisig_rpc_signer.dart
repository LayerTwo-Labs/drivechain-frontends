import 'dart:io';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

// Helper function to log multisig debugging information to file
Future<void> _logToFile(String message) async {
  try {
    final dir = Directory(path.dirname(path.current));
    final file = File(path.join(dir.path, 'bitwindow', 'multisig_output.txt'));
    
    // Ensure parent directory exists
    await file.parent.create(recursive: true);
    
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('[$timestamp] RPC_SIGNER: $message\n', mode: FileMode.append);
  } catch (e) {
    // Failed to write log file - continue silently
  }
}

/// Result of PSBT signing operation
class SigningResult {
  final String signedPsbt;
  final bool isComplete;
  final int signaturesAdded;
  final List<String> errors;
  
  SigningResult({
    required this.signedPsbt,
    required this.isComplete,
    required this.signaturesAdded,
    this.errors = const [],
  });
}

/// Handles PSBT signing for multisig wallets using descriptorprocesspsbt
class MultisigRPCSigner {
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();

  /// Signs a PSBT using Bitcoin Core descriptorprocesspsbt RPC
  Future<SigningResult> signPSBT({
    required String psbtBase64,
    required MultisigGroup group,
    required String mnemonic,
    required List<MultisigKey> walletKeys,
    bool isMainnet = false,
  }) async {
    await _logToFile('=== STARTING MULTISIG PSBT SIGNING ===');
    await _logToFile('Group: ${group.name} (${group.m}-of-${group.n})');
    await _logToFile('Total keys in group: ${group.keys.length}');
    await _logToFile('Wallet keys to sign with: ${walletKeys.length}');
    await _logToFile('Network: ${isMainnet ? "mainnet" : "signet/testnet"}');
    
    final errors = <String>[];
    
    try {
      // Validate we have the required descriptors
      if (group.descriptorReceive == null || group.descriptorChange == null) {
        throw Exception('Group missing descriptors - cannot sign');
      }
      
      await _logToFile('\nMultisig descriptors:');
      await _logToFile('  Receive: ${group.descriptorReceive!.substring(0, 50)}...');
      await _logToFile('  Change: ${group.descriptorChange!.substring(0, 50)}...');
      
      // Sign with each participant wallet
      final participantPSBTs = <String>[];
      int totalSignaturesAdded = 0;
      
      for (int i = 0; i < walletKeys.length; i++) {
        final walletKey = walletKeys[i];
        await _logToFile('\n=== Participant ${i + 1}/${walletKeys.length}: ${walletKey.owner} ===');
        
        try {
          final result = await _signWithParticipant(
            walletKey: walletKey,
            mnemonic: mnemonic,
            psbtBase64: psbtBase64,
            group: group,
            isMainnet: isMainnet,
          );
          
          if (result != null) {
            participantPSBTs.add(result.signedPsbt);
            totalSignaturesAdded += result.signaturesAdded;
            await _logToFile('✓ Participant signed successfully, added ${result.signaturesAdded} signatures');
          }
          
        } catch (e) {
          final error = 'Failed to sign with ${walletKey.owner}: $e';
          errors.add(error);
          await _logToFile('✗ $error');
          // Continue with other participants
        }
      }
      
      if (participantPSBTs.isEmpty) {
        throw Exception('No participants could sign the PSBT');
      }
      
      // Combine PSBTs if multiple participants signed
      String finalPsbt;
      if (participantPSBTs.length > 1) {
        await _logToFile('\n=== Combining ${participantPSBTs.length} signed PSBTs ===');
        finalPsbt = await _rpc.callRAW('combinepsbt', [participantPSBTs]) as String;
        await _logToFile('✓ PSBTs combined successfully');
      } else {
        finalPsbt = participantPSBTs[0];
        await _logToFile('✓ Using single participant PSBT');
      }
      
      // Check if complete
      final isComplete = await _checkPsbtComplete(finalPsbt, group.m);
      
      
      await _logToFile('\n=== SIGNING SUMMARY ===');
      await _logToFile('Participants who signed: ${participantPSBTs.length}/${walletKeys.length}');
      await _logToFile('Total signatures added: $totalSignaturesAdded');
      await _logToFile('Required signatures: ${group.m}');
      await _logToFile('Transaction complete: $isComplete');
      
      // Only return success if we actually added signatures
      if (totalSignaturesAdded == 0 && participantPSBTs.isNotEmpty) {
        errors.add('No signatures were added despite successful processing');
        await _logToFile('WARNING: Signing completed but no signatures were added');
      }
      
      return SigningResult(
        signedPsbt: finalPsbt,
        isComplete: isComplete,
        signaturesAdded: totalSignaturesAdded,
        errors: errors,
      );
      
    } catch (e) {
      await _logToFile('\nCRITICAL ERROR: $e');
      throw Exception('Multisig PSBT signing failed: $e');
    }
  }
  
  /// Sign PSBT with a single participant using descriptorprocesspsbt
  Future<SigningResult?> _signWithParticipant({
    required MultisigKey walletKey,
    required String mnemonic,
    required String psbtBase64,
    required MultisigGroup group,
    required bool isMainnet,
  }) async {
    try {
      // Step 1: Derive private key for this participant
      await _logToFile('Deriving private key for path: ${walletKey.derivationPath}');
      final keyInfo = await _hdWallet.deriveExtendedKeyInfo(mnemonic, walletKey.derivationPath, isMainnet);
      final xprv = keyInfo['xprv'];
      final fingerprint = keyInfo['fingerprint'];
      
      if (xprv == null || xprv.isEmpty) {
        throw Exception('Failed to derive extended private key for ${walletKey.owner}');
      }
      
      await _logToFile('Derived ${isMainnet ? "mainnet" : "testnet"} private key for ${walletKey.owner}');
      
      // Step 2: Build descriptors with private keys for this participant
      final descriptors = await _buildPrivateDescriptors(
        group, walletKey, xprv, fingerprint!,
      );
      
      await _logToFile('Built descriptors for signing: ${descriptors.length} descriptors');
      
      // Step 3: Use descriptorprocesspsbt to sign directly
      await _logToFile('Signing PSBT with descriptorprocesspsbt');
      await _logToFile('RPC call: descriptorprocesspsbt');
      await _logToFile('  PSBT: ${psbtBase64.substring(0, 50)}...');
      await _logToFile('  Descriptors: $descriptors');
      await _logToFile('  Parameters: sighashtype=ALL, bip32derivs=true, finalize=false');
      
      final result = await _rpc.callRAW('descriptorprocesspsbt', [
        psbtBase64,
        descriptors,
        'ALL', // sighashtype
        true,  // bip32derivs
        false, // finalize
      ]);
      
      await _logToFile('RPC response: $result');
      
      if (result is Map) {
        final signedPsbt = result['psbt'] as String;
        final isComplete = result['complete'] as bool? ?? false;
        
        // Count signatures added
        final signaturesAdded = await _countNewSignatures(psbtBase64, signedPsbt);
        
        await _logToFile('Signing result - complete: $isComplete, signatures: $signaturesAdded');
        
        return SigningResult(
          signedPsbt: signedPsbt,
          isComplete: isComplete,
          signaturesAdded: signaturesAdded,
          errors: [],
        );
      }
      
      throw Exception('Invalid response from descriptorprocesspsbt');
      
    } catch (e) {
      await _logToFile('Error signing with participant: $e');
      rethrow;
    }
  }
  
  
  
  /// Count new signatures added to PSBT
  Future<int> _countNewSignatures(String psbtBefore, String psbtAfter) async {
    try {
      // If PSBTs are different, assume signatures were added
      if (psbtBefore != psbtAfter) {
        await _logToFile('PSBT changed - assuming 1 signature added');
        return 1;
      }
      
      await _logToFile('PSBT unchanged - no signatures added');
      return 0;
    } catch (e) {
      await _logToFile('Could not count signatures: $e');
      return 0;
    }
  }
  
  /// Build descriptors with private keys for descriptorprocesspsbt
  Future<List<String>> _buildPrivateDescriptors(
    MultisigGroup group,
    MultisigKey thisKey,
    String thisXprv,
    String thisFingerprint,
  ) async {
    final originPath = thisKey.derivationPath.startsWith('m/') 
        ? thisKey.derivationPath.substring(2) 
        : thisKey.derivationPath;
    
    // Build multisig descriptors with this participant's private key
    final receiveDesc = await _buildMultisigDescriptorWithPrivateKey(
      group, thisKey, thisXprv, thisFingerprint, originPath, false, // external
    );
    
    final changeDesc = await _buildMultisigDescriptorWithPrivateKey(
      group, thisKey, thisXprv, thisFingerprint, originPath, true, // internal
    );
    
    await _logToFile('Built multisig descriptors with private key for ${thisKey.owner}');
    await _logToFile('  Receive: ${receiveDesc.substring(0, 60)}...');
    await _logToFile('  Change: ${changeDesc.substring(0, 60)}...');
    
    return [receiveDesc, changeDesc];
  }
  
  /// Build multisig descriptor with private key for this participant
  Future<String> _buildMultisigDescriptorWithPrivateKey(
    MultisigGroup group,
    MultisigKey thisKey,
    String thisXprv,
    String thisFingerprint,
    String thisOriginPath,
    bool isInternal,
  ) async {
    final chain = isInternal ? '1' : '0';
    final keys = <String>[];
    
    await _logToFile('Building descriptor for ${thisKey.owner}:');
    await _logToFile('  Private key: ${thisXprv.substring(0, 20)}...');
    await _logToFile('  Fingerprint: $thisFingerprint');
    await _logToFile('  Origin path: $thisOriginPath');
    await _logToFile('  Chain: $chain (${isInternal ? "internal" : "external"})');
    
    // Add all keys to the multisig
    for (final key in group.keys) {
      final keyOriginPath = key.derivationPath.startsWith('m/') 
          ? key.derivationPath.substring(2) 
          : key.derivationPath;
      
      if (key == thisKey) {
        // Use private key for this participant
        final keyDesc = '[$thisFingerprint/$thisOriginPath]$thisXprv/$chain/*';
        keys.add(keyDesc);
        await _logToFile('  Added THIS key (private): ${keyDesc.substring(0, 60)}...');
      } else {
        // Use public key for other participants
        final keyDesc = '[${key.fingerprint}/$keyOriginPath]${key.xpub}/$chain/*';
        keys.add(keyDesc);
        await _logToFile('  Added OTHER key (public): ${keyDesc.substring(0, 60)}...');
      }
    }
    
    // Sort keys for BIP 67 compliance (sortedmulti)
    keys.sort();
    await _logToFile('  Keys after sorting: ${keys.length} keys');
    
    // Build the descriptor (no checksum needed for descriptorprocesspsbt)
    final descriptor = 'wsh(sortedmulti(${group.m},${keys.join(',')}))';
    await _logToFile('  Final descriptor: ${descriptor.substring(0, 80)}...');
    
    return descriptor;
  }
  
  
  /// Check if PSBT has enough signatures
  Future<bool> _checkPsbtComplete(String psbt, int requiredSigs) async {
    try {
      final analysis = await _rpc.callRAW('analyzepsbt', [psbt]);
      
      if (analysis is Map) {
        final next = analysis['next'] as String?;
        final isComplete = next == 'finalizer' || next == 'extractor';
        
        await _logToFile('\nPSBT Analysis:');
        await _logToFile('  Next step: $next');
        await _logToFile('  Complete: $isComplete');
        
        // Check each input
        final inputs = analysis['inputs'] as List? ?? [];
        bool allInputsReady = true;
        
        for (int i = 0; i < inputs.length; i++) {
          final input = inputs[i] as Map?;
          if (input != null) {
            final sigs = (input['partial_signatures'] as Map?)?.length ?? 0;
            final hasUtxo = input['has_utxo'] as bool? ?? false;
            final isFinal = input['is_final'] as bool? ?? false;
            
            await _logToFile('  Input $i: signatures=$sigs/$requiredSigs, has_utxo=$hasUtxo, final=$isFinal');
            
            if (sigs < requiredSigs) {
              allInputsReady = false;
            }
          }
        }
        
        return isComplete && allInputsReady;
      }
      
      return false;
    } catch (e) {
      await _logToFile('Error analyzing PSBT: $e');
      return false;
    }
  }
  
}