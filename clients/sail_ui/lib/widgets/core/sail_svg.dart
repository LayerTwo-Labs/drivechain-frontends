import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailSVGAsset {
  iconTabPeg,
  iconTabBMM,
  iconTabWithdrawalExplorer,

  iconTabSidechainSend,

  iconTabZCashMeltCast,
  iconTabZCashShieldDeshield,
  iconTabZCashOperationStatuses,

  iconTabConsole,
  iconTabSettings,
  iconTabTools,
  iconTabStarters,

  iconCalendar,
  iconQuestion,
  iconSearch,
  iconCopy,
  iconRestart,
  iconArrow,
  iconArrowForward,
  iconClose,
  iconGlobe,
  iconExpand,
  iconDropdown,
  iconDeposit,
  iconWithdraw,
  iconFormat,
  iconMelt,
  iconCast,
  iconTerminal,
  iconNetwork,
  iconPeers,
  iconPen,
  iconCheck,
  iconNewWindow,
  iconTools,

  iconHome,
  iconSend,
  iconReceive,
  iconTransactions,
  iconSidechains,
  iconLearn,

  iconSuccess,
  iconPending,
  iconPendingHalf,
  iconFailed,
  iconInfo,
  iconSelected,
  iconCoins,
  iconConnectionStatus,
  iconWarning,
  iconWallet,
  iconCoinnews,
  iconDelete,
  iconMultisig,
  iconBitdrive,
  iconHDWallet,

  iconLightMode,
  iconDarkMode,
  iconLightDarkMode,

  meltCastDiagram,

  dividerDot,

  iconHandHelping,
  iconIconShield,
  iconUnderline,
  iconFilePlus2,
  iconSigma,
  iconIconMainchain,
  iconClock9,
  iconTriangleAlert,
  iconIconExpand,
  iconTriangle,
  iconHand,
  iconSignpostBig,
  iconVolume2,
  iconHandHeart,
  iconBarChartBig,
  iconContact,
  iconBeerOff,
  iconSendHorizontal,
  iconMoveDown,
  iconClipboardPlus,
  iconGamepad2,
  iconLectern,
  iconLasso,
  iconEraser,
  iconDisc2,
  iconReceipt,
  iconBedSingle,
  iconWine,
  iconBriefcaseMedical,
  iconIceCreamBowl,
  iconParkingMeter,
  iconFileSearch,
  iconArrowDown,
  iconFigma,
  iconCornerRightUp,
  iconFileKey,
  iconEarth,
  iconChevronsRight,
  iconBeef,
  iconFlashlight,
  iconFilePen,
  iconGhost,
  iconList,
  iconBicepsFlexed,
  iconCctv,
  iconTextCursorInput,
  iconMegaphone,
  iconCroissant,
  iconToyBrick,
  iconPencilOff,
  iconRouteOff,
  iconMessageCircleQuestion,
  iconSquareArrowRight,
  iconBriefcaseBusiness,
  iconSwissFranc,
  iconNavigation2Off,
  iconBluetoothOff,
  iconBed,
  iconIconNewWindow,
  iconPanelRightClose,
  iconSignalLow,
  iconChevronsDown,
  iconMemoryStick,
  iconDisc3,
  iconWind,
  iconCornerUpRight,
  iconClapperboard,
  iconSubscript,
  iconFileDigit,
  iconArrowBigDownDash,
  iconGrape,
  iconFlipVertical,
  iconHdmiPort,
  iconTarget,
  iconUserCog,
  iconScissors,
  iconMinimize2,
  iconCog,
  iconWaypoints,
  iconMegaphoneOff,
  iconReceiptPoundSterling,
  iconCrosshair,
  iconAlignVerticalDistributeEnd,
  iconPi,
  iconTableCellsMerge,
  iconSquareEqual,
  iconFileSliders,
  iconPackageOpen,
  iconVegan,
  iconAirplay,
  iconGalleryThumbnails,
  iconClock8,
  iconSection,
  iconMessageCircleWarning,
  iconBadgeEuro,
  iconRepeat,
  iconCircleUserRound,
  iconIconWithdraw,
  iconSquareChevronRight,
  iconArrowRightLeft,
  iconGrip,
  iconLuggage,
  iconHourglass,
  iconFileBarChart,
  iconRussianRuble,
  iconCircleChevronRight,
  iconMicrowave,
  iconIconLightMode,
  iconVolume1,
  iconPartyPopper,
  iconIconNetwork,
  iconBoxes,
  iconFileHeart,
  iconReply,
  iconBadgePercent,
  iconSquareDashedKanban,
  iconSunrise,
  iconToggleRight,
  iconIconMultisig,
  iconBugOff,
  iconIconSelected,
  iconMessageSquareShare,
  iconBeer,
  iconPointer,
  iconReceiptIndianRupee,
  iconSheet,
  iconSprayCan,
  iconScanLine,
  iconCircleCheckBig,
  iconUnfoldVertical,
  iconGitPullRequestDraft,
  iconLayoutList,
  iconUmbrella,
  iconUser,
  iconListStart,
  iconIconDarkMode,
  iconScatterChart,
  iconLassoSelect,
  iconArrowBigDown,
  iconIterationCw,
  iconFullscreen,
  iconIconFailed,
  iconMessageCircleHeart,
  iconSunDim,
  iconIconCoinnews,
  iconIconOpenInNew,
  iconReplaceAll,
  iconSquareArrowOutDownLeft,
  iconCannabis,
  iconIterationCcw,
  iconMessageCircleMore,
  iconFileMinus,
  iconSquarePower,
  iconSquareChevronUp,
  iconIconTabPeg,
  iconAlignHorizontalJustifyStart,
  iconCopyPlus,
  iconTimerOff,
  iconFolderCheck,
  iconBadgeJapaneseYen,
  iconArrowUpFromLine,
  iconFlipVertical2,
  iconAnnoyed,
  iconLigature,
  iconMessageSquareWarning,
  iconLayoutGrid,
  iconRockingChair,
  iconChevronsUpDown,
  iconBadgeMinus,
  iconCalendarOff,
  iconCircle,
  iconAirVent,
  iconPhoneMissed,
  iconScale3d,
  iconCornerLeftUp,
  iconMilk,
  iconClipboardPen,
  iconFileUp,
  iconCopyright,
  iconPictureInPicture,
  iconVault,
  iconCirclePower,
  iconMailbox,
  iconGitlab,
  iconMusic,
  iconFileBarChart2,
  iconRectangleEllipsis,
  iconSmartphone,
  iconFileSymlink,
  iconAlarmClockCheck,
  iconIconLearn,
  iconCandyOff,
  iconCircuitBoard,
  iconFolderTree,
  iconEqual,
  iconRecycle,
  iconArrowUpLeft,
  iconClipboardType,
  iconLibrary,
  iconPanelTopClose,
  iconIconTabSidechainSend,
  iconFilePieChart,
  iconSquareArrowDown,
  iconListPlus,
  iconChevronDown,
  iconBackpack,
  iconCalendarCheck2,
  iconHeading,
  iconHexagon,
  iconStrikethrough,
  iconCalendarFold,
  iconMessageSquareHeart,
  iconBird,
  iconBotMessageSquare,
  iconSunMedium,
  iconBadgeInfo,
  iconShieldPlus,
  iconBookMarked,
  iconCreativeCommons,
  iconShirt,
  iconDock,
  iconSignpost,
  iconDoorClosed,
  iconGithub,
  iconFoldHorizontal,
  iconNfc,
  iconClipboardPaste,
  iconCone,
  iconCookingPot,
  iconProportions,
  iconBringToFront,
  iconUsb,
  iconSeparatorVertical,
  iconBoxSelect,
  iconHardHat,
  iconCakeSlice,
  iconSunMoon,
  iconTicket,
  iconCalendarPlus2,
  iconCaseLower,
  iconLayoutTemplate,
  iconPanelRightOpen,
  iconBrackets,
  iconStarOff,
  iconShrink,
  iconChurch,
  iconCirclePercent,
  iconCrop,
  iconFlaskRound,
  iconIconTerminal,
  iconCookie,
  iconRedo2,
  iconCircleSlash2,
  iconTag,
  iconBookCheck,
  iconIconTabShieldDeshield,
  iconOctagonPause,
  iconCupSoda,
  iconOption,
  iconSparkle,
  iconBriefcase,
  iconCircleChevronDown,
  iconPresentation,
  iconSquareSigma,
  iconRotateCw,
  iconFileAudio,
  iconEllipsisVertical,
  iconBadgePlus,
  iconScreenShareOff,
  iconSquarePlay,
  iconAlignHorizontalDistributeEnd,
  iconFileClock,
  iconCalendarSearch,
  iconImageDown,
  iconSwatchBook,
  iconRadius,
  iconFolderSync,
  iconPanelsTopLeft,
  iconHeadset,
  iconCircleEqual,
  iconDessert,
  iconCarrot,
  iconReceiptEuro,
  iconMap,
  iconCheckCheck,
  iconInbox,
  iconCircleAlert,
  iconTvMinimal,
  iconAlignJustify,
  iconIconGlobe,
  iconPower,
  iconALargeSmall,
  iconTentTree,
  iconDatabase,
  iconCaptions,
  iconMartini,
  iconArrowUpToLine,
  iconMonitorDown,
  iconBadgeIndianRupee,
  iconCameraOff,
  iconFuel,
  iconSatelliteDish,
  iconBike,
  iconSwords,
  iconMessageSquareOff,
  iconScanText,
  iconArrowDownZA,
  iconRat,
  iconTornado,
  iconToggleLeft,
  iconFile,
  iconPuzzle,
  iconAlignVerticalDistributeCenter,
  iconSignal,
  iconEggOff,
  iconArrowUp10,
  iconFileAudio2,
  iconBaseline,
  iconVibrateOff,
  iconGlassWater,
  iconBrain,
  iconFiles,
  iconTorus,
  iconScanSearch,
  iconSquareDashedBottomCode,
  iconMessageCircle,
  iconMessageSquareDot,
  iconReceiptJapaneseYen,
  iconVoicemail,
  iconMessagesSquare,
  iconShipWheel,
  iconMessageSquareQuote,
  iconContrast,
  iconCuboid,
  iconAlarmClockPlus,
  iconMonitorPause,
  iconFileVideo2,
  iconArchiveX,
  iconMoveDiagonal,
  iconFileScan,
  iconArrowUpWideNarrow,
  iconMove,
  iconMaximize,
  iconBetweenVerticalStart,
  iconLaptopMinimal,
  iconRadar,
  iconIconPending,
  iconSparkles,
  iconLockKeyhole,
  iconOctagonX,
  iconFolderRoot,
  iconChevronUp,
  iconCircleHelp,
  iconSquarePercent,
  iconHaze,
  iconFolderOutput,
  iconFolderSymlink,
  iconFileBadge2,
  iconVibrate,
  iconLaugh,
  iconScanEye,
  iconSpade,
  iconCloudRainWind,
  iconSlidersVertical,
  iconIconWallet,
  iconUndo2,
  iconFileVideo,
  iconStepBack,
  iconFlaskConicalOff,
  iconArrowDownLeft,
  iconFileText,
  iconFileStack,
  iconFolderOpen,
  iconPackageMinus,
  iconDroplet,
  iconWholeWord,
  iconPaintRoller,
  iconZapOff,
  iconSquareKanban,
  iconKeyboard,
  iconX,
  iconChevronsRightLeft,
  iconJoystick,
  iconCigarette,
  iconBath,
  iconBarChart,
  iconQrCode,
  iconDot,
  iconIceCreamCone,
  iconLanguages,
  iconAmpersands,
  iconArrowLeftFromLine,
  iconBellMinus,
  iconFileCog,
  iconWheat,
  iconCableCar,
  iconArrowUpNarrowWide,
  iconLock,
  iconDice2,
  iconLogIn,
  iconSquircle,
  iconCloudUpload,
  iconShieldEllipsis,
  iconBan,
  iconSmartphoneNfc,
  iconListVideo,
  iconTextSelect,
  iconShoppingBag,
  iconDivide,
  iconPiggyBank,
  iconBatteryWarning,
  iconWalletMinimal,
  iconCircleDollarSign,
  iconMilkOff,
  iconSquareParking,
  iconRefreshCcwDot,
  iconTally2,
  iconShell,
  iconRepeat2,
  iconPilcrow,
  iconCircleDotDashed,
  iconMailQuestion,
  iconCloudDrizzle,
  iconCopyMinus,
  iconSpline,
  iconRefreshCw,
  iconIconCopy,
  iconPlane,
  iconAlignVerticalSpaceBetween,
  iconChevronRight,
  iconTally3,
  iconClipboard,
  iconEqualNot,
  iconPackage,
  iconInstagram,
  iconMailWarning,
  iconEuro,
  iconLink,
  iconSquareChevronLeft,
  iconGlobeLock,
  iconDice3,
  iconHandPlatter,
  iconVideoOff,
  iconUserRoundPlus,
  iconKey,
  iconSquareActivity,
  iconShrub,
  iconSailboat,
  iconFileX2,
  iconSquareSlash,
  iconBrainCog,
  iconMeh,
  iconSlidersHorizontal,
  iconDoorOpen,
  iconCornerDownRight,
  iconBeaker,
  iconListTodo,
  iconCloudSun,
  iconIconDownload,
  iconArrowRight,
  iconStore,
  iconAntenna,
  iconChevronFirst,
  iconWheatOff,
  iconAperture,
  iconCalendarPlus,
  iconBrush,
  iconThermometerSnowflake,
  iconClover,
  iconConciergeBell,
  iconLogOut,
  iconUnfoldHorizontal,
  iconFileSpreadsheet,
  iconSquareRadical,
  iconCirclePlay,
  iconSquareArrowUp,
  iconFileCode2,
  iconTelescope,
  iconShip,
  iconEarOff,
  iconWorm,
  iconWallpaper,
  iconAmbulance,
  iconSpace,
  iconFileInput,
  iconBarChart2,
  iconBookDashed,
  iconStretchVertical,
  iconCalendarCheck,
  iconDiff,
  iconShowerHead,
  iconSquarePen,
  iconArrowDownUp,
  iconGitPullRequest,
  iconMinimize,
  iconGroup,
  iconSettings,
  iconCloudSnow,
  iconNotepadTextDashed,
  iconCalendarX2,
  iconCassetteTape,
  iconThumbsDown,
  iconDice1,
  iconMoveDownLeft,
  iconVote,
  iconBotOff,
  iconType,
  iconSquareDashedMousePointer,
  iconSquareMenu,
  iconMousePointerClick,
  iconRegex,
  iconSquareCheckBig,
  iconIconQuestion,
  iconLoaderCircle,
  iconPopsicle,
  iconLampFloor,
  iconUtensils,
  iconArchive,
  iconIconSend,
  iconBean,
  iconPanelsRightBottom,
  iconMessageSquareText,
  iconRefreshCwOff,
  iconPhoneOutgoing,
  iconTally1,
  iconArrowUpFromDot,
  iconCandy,
  iconPocket,
  iconRepeat1,
  iconMagnet,
  iconCircleParking,
  iconMail,
  iconSchool,
  iconArrowBigRight,
  iconShield,
  iconDownload,
  iconKanban,
  iconFileVolume,
  iconGalleryVerticalEnd,
  iconFileWarning,
  iconDiscAlbum,
  iconPin,
  iconArrowUpAZ,
  iconSquareCheck,
  iconBarChartHorizontalBig,
  iconImport,
  iconWebcam,
  iconIconSearch,
  iconPhoneForwarded,
  iconBellPlus,
  iconSquareDot,
  iconCornerRightDown,
  iconSquareDivide,
  iconBookOpen,
  iconForklift,
  iconCalendarCog,
  iconCastle,
  iconAreaChart,
  iconOrbit,
  iconParentheses,
  iconProjector,
  iconPilcrowRight,
  iconServer,
  iconUserRoundCheck,
  iconBolt,
  iconTv,
  iconMessageSquareDashed,
  iconDroplets,
  iconSkipForward,
  iconArchiveRestore,
  iconVolume,
  iconLampWallUp,
  iconBarChart3,
  iconDrumstick,
  iconUserPlus,
  iconBatteryMedium,
  iconBookA,
  iconBatteryCharging,
  iconShapes,
  iconFolders,
  iconSatellite,
  iconListMinus,
  iconCircleArrowLeft,
  iconBookmarkMinus,
  iconHeater,
  iconLayers,
  iconEarthLock,
  iconSquareParkingOff,
  iconDna,
  iconMouseOff,
  iconFileCheck2,
  iconSlash,
  iconRadio,
  iconAlignCenterVertical,
  iconAlarmClock,
  iconAlarmClockOff,
  iconBook,
  iconKeyboardMusic,
  iconHotel,
  iconBookText,
  iconVariable,
  iconTouchpadOff,
  iconBitcoin,
  iconMessageSquareX,
  iconCarFront,
  iconAlarmSmoke,
  iconDice4,
  iconSkull,
  iconMailMinus,
  iconBot,
  iconPlug,
  iconShieldX,
  iconTrainTrack,
  iconGoal,
  iconFolderArchive,
  iconSignalHigh,
  iconUserMinus,
  iconPlaneLanding,
  iconCircleCheck,
  iconTally4,
  iconFileImage,
  iconSquareDashedBottom,
  iconPanelTopOpen,
  iconBell,
  iconGitBranch,
  iconSquareM,
  iconCoffee,
  iconPanelLeftDashed,
  iconCode,
  iconRailSymbol,
  iconCircleDivide,
  iconCake,
  iconSpellCheck2,
  iconSettings2,
  iconTally5,
  iconMessageCircleDashed,
  iconCloudMoonRain,
  iconRadioTower,
  iconThermometer,
  iconIconClose,
  iconMilestone,
  iconMove3d,
  iconFlag,
  iconPodcast,
  iconTvMinimalPlay,
  iconGitFork,
  iconEyeOff,
  iconDice5,
  iconTramFront,
  iconBattery,
  iconIconCoins,
  iconBlinds,
  iconArrowLeftToLine,
  iconNewspaper,
  iconClipboardPenLine,
  iconSnowflake,
  iconDisc,
  iconStepForward,
  iconBomb,
  iconPiano,
  iconBookCopy,
  iconArrowUp01,
  iconDatabaseZap,
  iconRotate3d,
  iconStarHalf,
  iconSwitchCamera,
  iconImagePlus,
  iconPencilRuler,
  iconContainer,
  iconRuler,
  iconTurtle,
  iconFrown,
  iconTreePine,
  iconAudioLines,
  iconCircleSlash,
  iconNotebookText,
  iconLayoutDashboard,
  iconFileLineChart,
  iconCpu,
  iconAlignEndHorizontal,
  iconFlameKindling,
  iconClipboardList,
  iconBiohazard,
  iconBarChart4,
  iconFolderX,
  iconBookOpenCheck,
  iconListOrdered,
  iconFactory,
  iconBold,
  iconTablets,
  iconIconTabWithdrawalExplorer,
  iconFence,
  iconTrophy,
  iconHash,
  iconShieldMinus,
  iconLink2Off,
  iconShare2,
  iconBatteryFull,
  iconPlus,
  iconMonitorStop,
  iconPanelBottom,
  iconClipboardMinus,
  iconAlignVerticalJustifyEnd,
  iconRabbit,
  iconPlugZap,
  iconNut,
  iconMailPlus,
  iconMoveDownRight,
  iconRotateCcw,
  iconHeartCrack,
  iconFlipHorizontal2,
  iconHardDrive,
  iconBetweenHorizontalEnd,
  iconTent,
  iconHardDriveDownload,
  iconCircleFadingPlus,
  iconPenLine,
  iconAlignVerticalSpaceAround,
  iconHospital,
  iconCaseSensitive,
  iconFocus,
  iconBluetooth,
  iconAlignEndVertical,
  iconPieChart,
  iconSquareSplitVertical,
  iconHeadphones,
  iconTableProperties,
  iconGitPullRequestCreateArrow,
  iconFolderGit2,
  iconSquareX,
  iconSquareAsterisk,
  iconRss,
  iconTableCellsSplit,
  iconFlower2,
  iconLandmark,
  iconWifi,
  iconCornerUpLeft,
  iconFileArchive,
  iconSquareArrowUpLeft,
  iconArrowDownFromLine,
  iconWatch,
  iconIconTransactions,
  iconSquareArrowDownRight,
  iconScale,
  iconDice6,
  iconMessageSquareMore,
  iconAmpersand,
  iconDnaOff,
  iconSquareArrowOutUpRight,
  iconHandCoins,
  iconRollerCoaster,
  iconMonitorSmartphone,
  iconGitCommitVertical,
  iconBlocks,
  iconPopcorn,
  iconFileBadge,
  iconBadgeDollarSign,
  iconUserX,
  iconIconSuccess,
  iconNavigationOff,
  iconKeySquare,
  iconTicketMinus,
  iconDog,
  iconLayoutPanelLeft,
  iconFan,
  iconRadioReceiver,
  iconLoader,
  iconPalette,
  iconPilcrowLeft,
  iconDiamondPlus,
  iconCircleArrowOutDownLeft,
  iconReceiptSwissFranc,
  iconPackage2,
  iconCaseUpper,
  iconRefreshCcw,
  iconCloudFog,
  iconIconArrowDown,
  iconGitBranchPlus,
  iconFileX,
  iconHeading1,
  iconHop,
  iconIconPen,
  iconFolderUp,
  iconSoup,
  iconFolderPlus,
  iconBadgeRussianRuble,
  iconGitMerge,
  iconJapaneseYen,
  iconGripHorizontal,
  iconListX,
  iconIconTabConsole,
  iconShieldHalf,
  iconMic,
  iconVenetianMask,
  iconRainbow,
  iconGitPullRequestArrow,
  iconIconArrowForward,
  iconSmilePlus,
  iconFish,
  iconMoveUpLeft,
  iconListTree,
  iconZoomIn,
  iconCircleChevronUp,
  iconCircleArrowOutDownRight,
  iconSquareGanttChart,
  iconSearchCheck,
  iconArrowDownToLine,
  iconGlasses,
  iconAlignStartVertical,
  iconArrowsUpFromLine,
  iconIconHdwallet,
  iconSnail,
  iconLibraryBig,
  iconBookmarkX,
  iconBookKey,
  iconPanelLeft,
  iconTestTubeDiagonal,
  iconOrigami,
  iconSquareLibrary,
  iconMessageCircleOff,
  iconSquareUserRound,
  iconWandSparkles,
  iconFileType2,
  iconTextQuote,
  iconCaravan,
  iconBadgeCent,
  iconPanelTopDashed,
  iconNotebookTabs,
  iconText,
  iconTestTubes,
  iconFireExtinguisher,
  iconEggFried,
  iconFlagTriangleLeft,
  iconAlignRight,
  iconTextCursor,
  iconImage,
  iconPanelBottomOpen,
  iconMaximize2,
  iconIconTabSend,
  iconLightbulb,
  iconServerOff,
  iconArrowBigLeftDash,
  iconImagePlay,
  iconSunset,
  iconSave,
  iconSmile,
  iconSearchCode,
  iconLamp,
  iconSiren,
  iconImages,
  iconScan,
  iconNavigation,
  iconCloudLightning,
  iconIconDashboardTab,
  iconCitrus,
  iconMessageSquareDiff,
  iconBellElectric,
  iconHam,
  iconCandlestickChart,
  iconMonitorPlay,
  iconBadgePoundSterling,
  iconHardDriveUpload,
  iconAppWindow,
  iconBadge,
  iconIconTabDepositWithdraw,
  iconTheater,
  iconIconSidechains,
  iconPaperclip,
  iconHeading2,
  iconSquareScissors,
  iconFastForward,
  iconFlagTriangleRight,
  iconCalendarRange,
  iconContactRound,
  iconSyringe,
  iconSearchSlash,
  iconFileQuestion,
  iconBarChartHorizontal,
  iconSticker,
  iconAward,
  iconPanelRightDashed,
  iconZoomOut,
  iconSquareArrowOutUpLeft,
  iconBox,
  iconThumbsUp,
  iconSuperscript,
  iconTicketPercent,
  iconBatteryLow,
  iconTouchpad,
  iconSpeech,
  iconIconConnectionStatus,
  iconPercent,
  iconSquareChevronDown,
  iconSquare,
  iconCrown,
  iconBluetoothSearching,
  iconTimerReset,
  iconStethoscope,
  iconIconSidechain,
  iconEclipse,
  iconDonut,
  iconCandyCane,
  iconPlay,
  iconFolderHeart,
  iconPenOff,
  iconFileCheck,
  iconLeafyGreen,
  iconTangent,
  iconBookAudio,
  iconTable,
  iconSplit,
  iconBarcode,
  iconVideotape,
  iconIconDelete,
  iconScroll,
  iconPhoneCall,
  iconColumns4,
  iconBaggageClaim,
  iconCircleArrowOutUpRight,
  iconRadiation,
  iconSpeaker,
  iconUserRoundSearch,
  iconUndoDot,
  iconFacebook,
  iconCodesandbox,
  iconFileDown,
  iconBadgeCheck,
  iconBaby,
  iconSmartphoneCharging,
  iconBookPlus,
  iconUnplug,
  iconHeading3,
  iconBluetoothConnected,
  iconIconCheck,
  iconCamera,
  iconLink2,
  iconPrinter,
  iconListCollapse,
  iconWorkflow,
  iconTrees,
  iconPanelLeftClose,
  iconGitGraph,
  iconRedo,
  iconCaptionsOff,
  iconClub,
  iconFolderMinus,
  iconMoveDiagonal2,
  iconCombine,
  iconArrowUpRight,
  iconTruck,
  iconLayoutPanelTop,
  iconLifeBuoy,
  iconUserSearch,
  iconSquareUser,
  iconTableColumnsSplit,
  iconBetweenHorizontalStart,
  iconPickaxe,
  iconPackageX,
  iconPenTool,
  iconAlarmClockMinus,
  iconPanelsLeftBottom,
  iconCircleGauge,
  iconFolderCog,
  iconAtSign,
  iconRotateCcwSquare,
  iconCircleArrowRight,
  iconShieldAlert,
  iconMapPinOff,
  iconListRestart,
  iconHandMetal,
  iconEgg,
  iconCarTaxiFront,
  iconSquareMousePointer,
  iconMonitorX,
  iconSquareTerminal,
  iconGrid2x2Check,
  iconBus,
  iconFilePenLine,
  iconIconCast,
  iconBookHeart,
  iconInfinity,
  iconGem,
  iconFilterX,
  iconGitCompare,
  iconReceiptCent,
  iconFeather,
  iconWebhookOff,
  iconTrash,
  iconTreePalm,
  iconArrowDown10,
  iconDatabaseBackup,
  iconArmchair,
  iconWifiOff,
  iconUserRound,
  iconUngroup,
  iconBookLock,
  iconLeaf,
  iconArrowDownWideNarrow,
  iconFileLock2,
  iconAppWindowMac,
  iconArrowUpZA,
  iconScanBarcode,
  iconCornerLeftDown,
  iconMessageSquarePlus,
  iconFolderClock,
  iconPaintbrushVertical,
  iconDollarSign,
  iconTriangleRight,
  iconIndianRupee,
  iconConstruction,
  iconCirclePlus,
  iconGraduationCap,
  iconScanFace,
  iconFishSymbol,
  iconMonitorSpeaker,
  iconGuitar,
  iconStar,
  iconLockKeyholeOpen,
  iconMonitorCheck,
  iconSandwich,
  iconChefHat,
  iconHeading6,
  iconCloudOff,
  iconSaveAll,
  iconSun,
  iconWrench,
  iconSignalMedium,
  iconGrab,
  iconPyramid,
  iconBookMinus,
  iconGauge,
  iconIconInfo,
  iconMessageSquare,
  iconBugPlay,
  iconBookX,
  iconHeading4,
  iconPizza,
  iconUnlink,
  iconChevronsDownUp,
  iconBone,
  iconFlashlightOff,
  iconFileJson2,
  iconAnchor,
  iconHammer,
  iconPlug2,
  iconNotebookPen,
  iconChevronsUp,
  iconColumns3,
  iconMoveHorizontal,
  iconHighlighter,
  iconSquareArrowUpRight,
  iconTabletSmartphone,
  iconCircleStop,
  iconTwitch,
  iconBanana,
  iconTreeDeciduous,
  iconFolderLock,
  iconIconRestart,
  iconLocate,
  iconListMusic,
  iconBug,
  iconPanelTop,
  iconMessageSquareCode,
  iconMailOpen,
  iconYoutube,
  iconChevronsLeftRight,
  iconBookmarkPlus,
  iconAArrowUp,
  iconTowerControl,
  iconBookUp,
  iconPocketKnife,
  iconShovel,
  iconCompass,
  iconFileMinus2,
  iconAlignHorizontalJustifyEnd,
  iconServerCrash,
  iconTrafficCone,
  iconPlaneTakeoff,
  iconIconTabStarters,
  iconFolderKanban,
  iconMailSearch,
  iconImageUp,
  iconCloudMoon,
  iconColumns2,
  iconWarehouse,
  iconRotateCwSquare,
  iconSquareFunction,
  iconFrame,
  iconCreditCard,
  iconCircleArrowDown,
  iconTable2,
  iconFileKey2,
  iconCopyleft,
  iconGrid3x3,
  iconTicketX,
  iconAlignVerticalJustifyStart,
  iconHeartOff,
  iconCylinder,
  iconComputer,
  iconBookType,
  iconPillBottle,
  iconHeading5,
  iconThermometerSun,
  iconBadgeHelp,
  iconLocateOff,
  iconReplyAll,
  iconPencil,
  iconCloudRain,
  iconSendToBack,
  iconIconTabOperationStatuses,
  iconGitPullRequestClosed,
  iconArrowBigRightDash,
  iconAlignVerticalDistributeStart,
  iconBookDown,
  iconIconCalendar,
  iconPoundSterling,
  iconMonitorUp,
  iconBeanOff,
  iconTrash2,
  iconCircleUser,
  iconSkipBack,
  iconFilePlus,
  iconScrollText,
  iconGanttChart,
  iconDiamond,
  iconCommand,
  iconPackageCheck,
  iconAlignCenterHorizontal,
  iconClock,
  iconBellRing,
  iconRemoveFormatting,
  iconRouter,
  iconFootprints,
  iconOctagon,
  iconArrowBigLeft,
  iconTableRowsSplit,
  iconPhone,
  iconCircleX,
  iconLandPlot,
  iconAlignHorizontalJustifyCenter,
  iconSunSnow,
  iconIconDeposit,
  iconImageOff,
  iconUmbrellaOff,
  iconArrowDownAZ,
  iconPanelLeftOpen,
  iconBrainCircuit,
  iconMoveVertical,
  iconUsersRound,
  iconSalad,
  iconDumbbell,
  iconTractor,
  iconWaves,
  iconFolderClosed,
  iconEye,
  iconUserRoundCog,
  iconIndentIncrease,
  iconMousePointerBan,
  iconBadgeAlert,
  iconServerCog,
  iconPipette,
  iconPhoneOff,
  iconFlower,
  iconBanknote,
  iconSprout,
  iconBrickWall,
  iconCopyCheck,
  iconRectangleVertical,
  iconPill,
  iconCodepen,
  iconDribbble,
  iconMessageCirclePlus,
  iconAxe,
  iconSquarePlus,
  iconGift,
  iconReceiptRussianRuble,
  iconPackagePlus,
  iconIconReceive,
  iconExternalLink,
  iconLineChart,
  iconCurrency,
  iconWand,
  iconFileMusic,
  iconCar,
  iconZap,
  iconTrello,
  iconListChecks,
  iconMessageSquareReply,
  iconBadgeX,
  iconIconWarning,
  iconBuilding2,
  iconMoonStar,
  iconClock1,
  iconCigaretteOff,
  iconBinary,
  iconChevronLast,
  iconPointerOff,
  iconMousePointer2,
  iconPackageSearch,
  iconMicOff,
  iconLampDesk,
  iconShare,
  iconCircleParkingOff,
  iconTags,
  iconSquareBottomDashedScissors,
  iconIconTabBmm,
  iconAlbum,
  iconKeyRound,
  iconSquareCode,
  iconIconLightDarkMode,
  iconFolderSearch2,
  iconArrowUp,
  iconCircleArrowOutUpLeft,
  iconMicroscope,
  iconTestTube,
  iconBellOff,
  iconLinkedin,
  iconArrowDownNarrowWide,
  iconClock3,
  iconPanelRight,
  iconDrum,
  iconView,
  iconMusic2,
  iconWrapText,
  iconGitCompareArrows,
  iconCalendarMinus,
  iconBookImage,
  iconFileVolume2,
  iconUserRoundX,
  iconUndo,
  iconVideo,
  iconIconHome,
  iconCircleEllipsis,
  iconActivity,
  iconPencilLine,
  iconIconFormat,
  iconPersonStanding,
  iconTwitter,
  iconMapPin,
  iconFolderInput,
  iconFilter,
  iconLightbulbOff,
  iconPhoneIncoming,
  iconRefrigerator,
  iconItalic,
  iconListEnd,
  iconHandshake,
  iconChevronsLeft,
  iconRows2,
  iconMailX,
  iconMedal,
  iconMessageCircleCode,
  iconInspectionPanel,
  iconNotepadText,
  iconMessageCircleX,
  iconArrowRightFromLine,
  iconArrowLeft,
  iconPaintbrush,
  iconRows3,
  iconAlignCenter,
  iconBadgeSwissFranc,
  iconCross,
  iconSquareMinus,
  iconUniversity,
  iconRoute,
  iconCircleArrowUp,
  iconDiameter,
  iconPcCase,
  iconEllipsis,
  iconCalendarHeart,
  iconIconDropdown,
  iconBookHeadphones,
  iconArrowDownRight,
  iconFileBox,
  iconPawPrint,
  iconLaptop,
  iconIconPeers,
  iconPowerOff,
  iconRedoDot,
  iconAxis3d,
  iconArrowBigUp,
  iconFramer,
  iconKeyboardOff,
  iconMountain,
  iconStretchHorizontal,
  iconBellDot,
  iconClipboardX,
  iconFolderDown,
  iconShieldQuestion,
  iconPanelBottomDashed,
  iconVolumeX,
  iconMusic3,
  iconCopySlash,
  iconFileCode,
  iconMoveLeft,
  iconSlack,
  iconCircleDashed,
  iconClock2,
  iconUserRoundMinus,
  iconScissorsLineDashed,
  iconFileOutput,
  iconCloud,
  iconHopOff,
  iconIconMelt,
  iconClock11,
  iconShuffle,
  iconQuote,
  iconAnvil,
  iconWashingMachine,
  iconGripVertical,
  iconClock6,
  iconDrill,
  iconPlugZap2,
  iconAlignHorizontalDistributeStart,
  iconFileType,
  iconRewind,
  iconWineOff,
  iconUpload,
  iconTrendingDown,
  iconDividerDot,
  iconBookmarkCheck,
  iconFoldVertical,
  iconCalendarX,
  iconPause,
  iconRadical,
  iconArrowBigUpDash,
  iconFolderKey,
  iconGrid2x2,
  iconCloudHail,
  iconSearchX,
  iconCloudy,
  iconReplace,
  iconForward,
  iconMountainSnow,
  iconIconTools,
  iconIndentDecrease,
  iconCircleMinus,
  iconIconPendingHalf,
  iconDices,
  iconBlend,
  iconBookmark,
  iconBraces,
  iconRocket,
  iconCircleDot,
  iconMoveRight,
  iconDrama,
  iconAsterisk,
  iconUserCheck,
  iconCalendarClock,
  iconFishOff,
  iconFolderSearch,
  iconFolderPen,
  iconCloudSunRain,
  iconGitPullRequestCreate,
  iconTablet,
  iconMailCheck,
  iconAlignVerticalJustifyCenter,
  iconFileDiff,
  iconMonitorDot,
  iconTicketSlash,
  iconAlignHorizontalSpaceBetween,
  iconWebhook,
  iconDiamondPercent,
  iconFolderOpenDot,
  iconArrowLeftRight,
  iconIconTabSettings,
  iconCodeXml,
  iconCloudDownload,
  iconUtilityPole,
  iconSignalZero,
  iconBookUp2,
  iconMonitorOff,
  iconEar,
  iconSpellCheck,
  iconFileTerminal,
  iconFlame,
  iconIconTabMeltCast,
  iconGalleryHorizontalEnd,
  iconNutOff,
  iconComponent,
  iconCircleOff,
  iconFileSearch2,
  iconAlignStartHorizontal,
  iconLocateFixed,
  iconLockOpen,
  iconLoaderPinwheel,
  iconAtom,
  iconCat,
  iconCloudCog,
  iconSword,
  iconSquarePilcrow,
  iconSquirrel,
  iconMenu,
  iconPinOff,
  iconLampCeiling,
  iconFolderDot,
  iconUtensilsCrossed,
  iconRatio,
  iconSquareArrowDownLeft,
  iconGrid2x2X,
  iconOctagonAlert,
  iconGalleryVertical,
  iconImageMinus,
  iconClock7,
  iconArrowRightToLine,
  iconAArrowDown,
  iconMerge,
  iconMapPinned,
  iconSquarePi,
  iconAlignHorizontalSpaceAround,
  iconChrome,
  iconStickyNote,
  iconTicketPlus,
  iconShoppingCart,
  iconCopyX,
  iconCalculator,
  iconClock10,
  iconTrainFrontTunnel,
  iconClock12,
  iconApple,
  iconCircleChevronLeft,
  iconMouse,
  iconFlaskConical,
  iconPictureInPicture2,
  iconPentagon,
  iconDiamondMinus,
  iconShieldCheck,
  iconArrowDown01,
  iconMessageCircleReply,
  iconCirclePause,
  iconMails,
  iconClock5,
  iconRectangleHorizontal,
  iconShoppingBasket,
  iconListFilter,
  iconReceiptText,
  iconMusic4,
  iconBookUser,
  iconShieldBan,
  iconArrowDownToDot,
  iconBuilding,
  iconIconBitdrive,
  iconClipboardCopy,
  iconAngry,
  iconLollipop,
  iconBetweenVerticalEnd,
  iconHistory,
  iconGavel,
  iconFolder,
  iconDraftingCompass,
  iconAlignHorizontalDistributeCenter,
  iconFileLock,
  iconLayers2,
  iconUsers,
  iconBoomBox,
  iconSlice,
  iconFolderGit,
  iconFingerprint,
  iconFlagOff,
  iconMicVocal,
  iconCornerDownLeft,
  iconFileAxis3d,
  iconBookOpenText,
  iconTimer,
  iconGamepad,
  iconGitCommitHorizontal,
  iconMonitor,
  iconClipboardCheck,
  iconUnlink2,
  iconSquareArrowOutDownRight,
  iconMinus,
  iconHeartPulse,
  iconRows4,
  iconHeartHandshake,
  iconBedDouble,
  iconTextSearch,
  iconAudioWaveform,
  iconNavigation2,
  iconPaintBucket,
  iconChevronLeft,
  iconMoveUp,
  iconFilm,
  iconMoon,
  iconSquareArrowLeft,
  iconPanelBottomClose,
  iconWeight,
  iconShieldOff,
  iconLayers3,
  iconScaling,
  iconCable,
  iconAccessibility,
  iconMoveUpRight,
  iconWalletCards,
  iconBusFront,
  iconLampWallDown,
  iconMousePointer,
  iconFileJson,
  iconTrainFront,
  iconCalendarMinus2,
  iconRibbon,
  iconSquareStack,
  iconFlipHorizontal,
  iconGalleryHorizontal,
  iconNotebook,
  iconStamp,
  iconSquareSplitHorizontal,
  iconArrowUpDown,
  iconIconTabTools,
  iconScreenShare,
  iconCalendarDays,
  iconAlignLeft,
  iconSeparatorHorizontal,
  iconFerrisWheel,
  iconSofa,
  iconClock4,
  iconTicketCheck,
  iconCherry,
  iconHeart,
  iconTrendingUp,
}

enum SailPNGAsset {
  meltCastDiagram,
  articleBeginner,
}

/// If you don't want to overwrite the color of the svg, put it in here!
// useful for svgs that already have a color like red or blue, that are
// not supposed to be the same color of the text, or ones that have
// multiple colors
const coloredAssets = [
  SailSVGAsset.iconSuccess,
  SailSVGAsset.iconPending,
  SailSVGAsset.iconPendingHalf,
  SailSVGAsset.iconFailed,
  SailSVGAsset.iconInfo,
];

class SailSVG {
  static Widget icon(
    SailSVGAsset asset, {
    bool isHighlighted = false,
    double? width,
    double? height,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final colors = SailTheme.of(context).colors;

        return SailSVG.fromAsset(
          asset,
          color: color ?? (coloredAssets.contains(asset) ? null : (isHighlighted ? colors.primary : colors.icon)),
          width: width ?? SailStyleValues.iconSizePrimary,
          height: height ?? SailStyleValues.iconSizePrimary,
        );
      },
    );
  }

  static SvgPicture fromAsset(
    SailSVGAsset asset, {
    double? height,
    double? width,
    Color? color,
  }) {
    return SvgPicture.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      height: height,
    );
  }

  static Widget png(
    SailPNGAsset asset, {
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.asset(
      asset.toAssetPath(),
      package: 'sail_ui',
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }
}

extension AsAssetPath on SailSVGAsset {
  String toAssetPath() {
    switch (this) {
      case SailSVGAsset.iconHandHelping:
        return 'assets/svgs/hand-helping.svg';
      case SailSVGAsset.iconIconShield:
        return 'assets/svgs/icon_shield.svg';
      case SailSVGAsset.iconUnderline:
        return 'assets/svgs/underline.svg';
      case SailSVGAsset.iconFilePlus2:
        return 'assets/svgs/file-plus-2.svg';
      case SailSVGAsset.iconSigma:
        return 'assets/svgs/sigma.svg';
      case SailSVGAsset.iconIconMainchain:
        return 'assets/svgs/icon_mainchain.svg';
      case SailSVGAsset.iconClock9:
        return 'assets/svgs/clock-9.svg';
      case SailSVGAsset.iconTriangleAlert:
        return 'assets/svgs/triangle-alert.svg';
      case SailSVGAsset.iconIconExpand:
        return 'assets/svgs/icon_expand.svg';
      case SailSVGAsset.iconTriangle:
        return 'assets/svgs/triangle.svg';
      case SailSVGAsset.iconHand:
        return 'assets/svgs/hand.svg';
      case SailSVGAsset.iconSignpostBig:
        return 'assets/svgs/signpost-big.svg';
      case SailSVGAsset.iconVolume2:
        return 'assets/svgs/volume-2.svg';
      case SailSVGAsset.iconHandHeart:
        return 'assets/svgs/hand-heart.svg';
      case SailSVGAsset.iconBarChartBig:
        return 'assets/svgs/bar-chart-big.svg';
      case SailSVGAsset.iconContact:
        return 'assets/svgs/contact.svg';
      case SailSVGAsset.iconBeerOff:
        return 'assets/svgs/beer-off.svg';
      case SailSVGAsset.iconSendHorizontal:
        return 'assets/svgs/send-horizontal.svg';
      case SailSVGAsset.iconMoveDown:
        return 'assets/svgs/move-down.svg';
      case SailSVGAsset.iconClipboardPlus:
        return 'assets/svgs/clipboard-plus.svg';
      case SailSVGAsset.iconGamepad2:
        return 'assets/svgs/gamepad-2.svg';
      case SailSVGAsset.iconLectern:
        return 'assets/svgs/lectern.svg';
      case SailSVGAsset.iconLasso:
        return 'assets/svgs/lasso.svg';
      case SailSVGAsset.iconEraser:
        return 'assets/svgs/eraser.svg';
      case SailSVGAsset.iconDisc2:
        return 'assets/svgs/disc-2.svg';
      case SailSVGAsset.iconReceipt:
        return 'assets/svgs/receipt.svg';
      case SailSVGAsset.iconBedSingle:
        return 'assets/svgs/bed-single.svg';
      case SailSVGAsset.iconWine:
        return 'assets/svgs/wine.svg';
      case SailSVGAsset.iconBriefcaseMedical:
        return 'assets/svgs/briefcase-medical.svg';
      case SailSVGAsset.iconIceCreamBowl:
        return 'assets/svgs/ice-cream-bowl.svg';
      case SailSVGAsset.iconParkingMeter:
        return 'assets/svgs/parking-meter.svg';
      case SailSVGAsset.iconFileSearch:
        return 'assets/svgs/file-search.svg';
      case SailSVGAsset.iconArrowDown:
        return 'assets/svgs/arrow-down.svg';
      case SailSVGAsset.iconFigma:
        return 'assets/svgs/figma.svg';
      case SailSVGAsset.iconCornerRightUp:
        return 'assets/svgs/corner-right-up.svg';
      case SailSVGAsset.iconFileKey:
        return 'assets/svgs/file-key.svg';
      case SailSVGAsset.iconEarth:
        return 'assets/svgs/earth.svg';
      case SailSVGAsset.iconChevronsRight:
        return 'assets/svgs/chevrons-right.svg';
      case SailSVGAsset.iconBeef:
        return 'assets/svgs/beef.svg';
      case SailSVGAsset.iconFlashlight:
        return 'assets/svgs/flashlight.svg';
      case SailSVGAsset.iconFilePen:
        return 'assets/svgs/file-pen.svg';
      case SailSVGAsset.iconGhost:
        return 'assets/svgs/ghost.svg';
      case SailSVGAsset.iconList:
        return 'assets/svgs/list.svg';
      case SailSVGAsset.iconBicepsFlexed:
        return 'assets/svgs/biceps-flexed.svg';
      case SailSVGAsset.iconCctv:
        return 'assets/svgs/cctv.svg';
      case SailSVGAsset.iconTextCursorInput:
        return 'assets/svgs/text-cursor-input.svg';
      case SailSVGAsset.iconMegaphone:
        return 'assets/svgs/megaphone.svg';
      case SailSVGAsset.iconCroissant:
        return 'assets/svgs/croissant.svg';
      case SailSVGAsset.iconToyBrick:
        return 'assets/svgs/toy-brick.svg';
      case SailSVGAsset.iconPencilOff:
        return 'assets/svgs/pencil-off.svg';
      case SailSVGAsset.iconRouteOff:
        return 'assets/svgs/route-off.svg';
      case SailSVGAsset.iconMessageCircleQuestion:
        return 'assets/svgs/message-circle-question.svg';
      case SailSVGAsset.iconSquareArrowRight:
        return 'assets/svgs/square-arrow-right.svg';
      case SailSVGAsset.iconBriefcaseBusiness:
        return 'assets/svgs/briefcase-business.svg';
      case SailSVGAsset.iconSwissFranc:
        return 'assets/svgs/swiss-franc.svg';
      case SailSVGAsset.iconNavigation2Off:
        return 'assets/svgs/navigation-2-off.svg';
      case SailSVGAsset.iconBluetoothOff:
        return 'assets/svgs/bluetooth-off.svg';
      case SailSVGAsset.iconBed:
        return 'assets/svgs/bed.svg';
      case SailSVGAsset.iconIconNewWindow:
        return 'assets/svgs/icon_new_window.svg';
      case SailSVGAsset.iconPanelRightClose:
        return 'assets/svgs/panel-right-close.svg';
      case SailSVGAsset.iconSignalLow:
        return 'assets/svgs/signal-low.svg';
      case SailSVGAsset.iconChevronsDown:
        return 'assets/svgs/chevrons-down.svg';
      case SailSVGAsset.iconMemoryStick:
        return 'assets/svgs/memory-stick.svg';
      case SailSVGAsset.iconDisc3:
        return 'assets/svgs/disc-3.svg';
      case SailSVGAsset.iconWind:
        return 'assets/svgs/wind.svg';
      case SailSVGAsset.iconCornerUpRight:
        return 'assets/svgs/corner-up-right.svg';
      case SailSVGAsset.iconClapperboard:
        return 'assets/svgs/clapperboard.svg';
      case SailSVGAsset.iconSubscript:
        return 'assets/svgs/subscript.svg';
      case SailSVGAsset.iconFileDigit:
        return 'assets/svgs/file-digit.svg';
      case SailSVGAsset.iconArrowBigDownDash:
        return 'assets/svgs/arrow-big-down-dash.svg';
      case SailSVGAsset.iconGrape:
        return 'assets/svgs/grape.svg';
      case SailSVGAsset.iconFlipVertical:
        return 'assets/svgs/flip-vertical.svg';
      case SailSVGAsset.iconHdmiPort:
        return 'assets/svgs/hdmi-port.svg';
      case SailSVGAsset.iconTarget:
        return 'assets/svgs/target.svg';
      case SailSVGAsset.iconUserCog:
        return 'assets/svgs/user-cog.svg';
      case SailSVGAsset.iconScissors:
        return 'assets/svgs/scissors.svg';
      case SailSVGAsset.iconMinimize2:
        return 'assets/svgs/minimize-2.svg';
      case SailSVGAsset.iconCog:
        return 'assets/svgs/cog.svg';
      case SailSVGAsset.iconWaypoints:
        return 'assets/svgs/waypoints.svg';
      case SailSVGAsset.iconMegaphoneOff:
        return 'assets/svgs/megaphone-off.svg';
      case SailSVGAsset.iconReceiptPoundSterling:
        return 'assets/svgs/receipt-pound-sterling.svg';
      case SailSVGAsset.iconCrosshair:
        return 'assets/svgs/crosshair.svg';
      case SailSVGAsset.iconAlignVerticalDistributeEnd:
        return 'assets/svgs/align-vertical-distribute-end.svg';
      case SailSVGAsset.iconPi:
        return 'assets/svgs/pi.svg';
      case SailSVGAsset.iconTableCellsMerge:
        return 'assets/svgs/table-cells-merge.svg';
      case SailSVGAsset.iconSquareEqual:
        return 'assets/svgs/square-equal.svg';
      case SailSVGAsset.iconFileSliders:
        return 'assets/svgs/file-sliders.svg';
      case SailSVGAsset.iconPackageOpen:
        return 'assets/svgs/package-open.svg';
      case SailSVGAsset.iconVegan:
        return 'assets/svgs/vegan.svg';
      case SailSVGAsset.iconAirplay:
        return 'assets/svgs/airplay.svg';
      case SailSVGAsset.iconGalleryThumbnails:
        return 'assets/svgs/gallery-thumbnails.svg';
      case SailSVGAsset.iconClock8:
        return 'assets/svgs/clock-8.svg';
      case SailSVGAsset.iconSection:
        return 'assets/svgs/section.svg';
      case SailSVGAsset.iconMessageCircleWarning:
        return 'assets/svgs/message-circle-warning.svg';
      case SailSVGAsset.iconBadgeEuro:
        return 'assets/svgs/badge-euro.svg';
      case SailSVGAsset.iconRepeat:
        return 'assets/svgs/repeat.svg';
      case SailSVGAsset.iconCircleUserRound:
        return 'assets/svgs/circle-user-round.svg';
      case SailSVGAsset.iconIconWithdraw:
        return 'assets/svgs/icon_withdraw.svg';
      case SailSVGAsset.iconSquareChevronRight:
        return 'assets/svgs/square-chevron-right.svg';
      case SailSVGAsset.iconArrowRightLeft:
        return 'assets/svgs/arrow-right-left.svg';
      case SailSVGAsset.iconGrip:
        return 'assets/svgs/grip.svg';
      case SailSVGAsset.iconLuggage:
        return 'assets/svgs/luggage.svg';
      case SailSVGAsset.iconHourglass:
        return 'assets/svgs/hourglass.svg';
      case SailSVGAsset.iconFileBarChart:
        return 'assets/svgs/file-bar-chart.svg';
      case SailSVGAsset.iconRussianRuble:
        return 'assets/svgs/russian-ruble.svg';
      case SailSVGAsset.iconCircleChevronRight:
        return 'assets/svgs/circle-chevron-right.svg';
      case SailSVGAsset.iconMicrowave:
        return 'assets/svgs/microwave.svg';
      case SailSVGAsset.iconIconLightMode:
        return 'assets/svgs/icon_light_mode.svg';
      case SailSVGAsset.iconVolume1:
        return 'assets/svgs/volume-1.svg';
      case SailSVGAsset.iconPartyPopper:
        return 'assets/svgs/party-popper.svg';
      case SailSVGAsset.iconIconNetwork:
        return 'assets/svgs/icon_network.svg';
      case SailSVGAsset.iconBoxes:
        return 'assets/svgs/boxes.svg';
      case SailSVGAsset.iconFileHeart:
        return 'assets/svgs/file-heart.svg';
      case SailSVGAsset.iconReply:
        return 'assets/svgs/reply.svg';
      case SailSVGAsset.iconBadgePercent:
        return 'assets/svgs/badge-percent.svg';
      case SailSVGAsset.iconSquareDashedKanban:
        return 'assets/svgs/square-dashed-kanban.svg';
      case SailSVGAsset.iconSunrise:
        return 'assets/svgs/sunrise.svg';
      case SailSVGAsset.iconToggleRight:
        return 'assets/svgs/toggle-right.svg';
      case SailSVGAsset.iconIconMultisig:
        return 'assets/svgs/icon_multisig.svg';
      case SailSVGAsset.iconBugOff:
        return 'assets/svgs/bug-off.svg';
      case SailSVGAsset.iconIconSelected:
        return 'assets/svgs/icon_selected.svg';
      case SailSVGAsset.iconMessageSquareShare:
        return 'assets/svgs/message-square-share.svg';
      case SailSVGAsset.iconBeer:
        return 'assets/svgs/beer.svg';
      case SailSVGAsset.iconPointer:
        return 'assets/svgs/pointer.svg';
      case SailSVGAsset.iconReceiptIndianRupee:
        return 'assets/svgs/receipt-indian-rupee.svg';
      case SailSVGAsset.iconSheet:
        return 'assets/svgs/sheet.svg';
      case SailSVGAsset.iconSprayCan:
        return 'assets/svgs/spray-can.svg';
      case SailSVGAsset.iconScanLine:
        return 'assets/svgs/scan-line.svg';
      case SailSVGAsset.iconCircleCheckBig:
        return 'assets/svgs/circle-check-big.svg';
      case SailSVGAsset.iconUnfoldVertical:
        return 'assets/svgs/unfold-vertical.svg';
      case SailSVGAsset.iconGitPullRequestDraft:
        return 'assets/svgs/git-pull-request-draft.svg';
      case SailSVGAsset.iconLayoutList:
        return 'assets/svgs/layout-list.svg';
      case SailSVGAsset.iconUmbrella:
        return 'assets/svgs/umbrella.svg';
      case SailSVGAsset.iconUser:
        return 'assets/svgs/user.svg';
      case SailSVGAsset.iconListStart:
        return 'assets/svgs/list-start.svg';
      case SailSVGAsset.iconIconDarkMode:
        return 'assets/svgs/icon_dark_mode.svg';
      case SailSVGAsset.iconScatterChart:
        return 'assets/svgs/scatter-chart.svg';
      case SailSVGAsset.iconLassoSelect:
        return 'assets/svgs/lasso-select.svg';
      case SailSVGAsset.iconArrowBigDown:
        return 'assets/svgs/arrow-big-down.svg';
      case SailSVGAsset.iconIterationCw:
        return 'assets/svgs/iteration-cw.svg';
      case SailSVGAsset.iconFullscreen:
        return 'assets/svgs/fullscreen.svg';
      case SailSVGAsset.iconIconFailed:
        return 'assets/svgs/icon_failed.svg';
      case SailSVGAsset.iconMessageCircleHeart:
        return 'assets/svgs/message-circle-heart.svg';
      case SailSVGAsset.iconSunDim:
        return 'assets/svgs/sun-dim.svg';
      case SailSVGAsset.iconIconCoinnews:
        return 'assets/svgs/icon_coinnews.svg';
      case SailSVGAsset.iconIconOpenInNew:
        return 'assets/svgs/icon_open_in_new.svg';
      case SailSVGAsset.iconReplaceAll:
        return 'assets/svgs/replace-all.svg';
      case SailSVGAsset.iconSquareArrowOutDownLeft:
        return 'assets/svgs/square-arrow-out-down-left.svg';
      case SailSVGAsset.iconCannabis:
        return 'assets/svgs/cannabis.svg';
      case SailSVGAsset.iconIterationCcw:
        return 'assets/svgs/iteration-ccw.svg';
      case SailSVGAsset.iconMessageCircleMore:
        return 'assets/svgs/message-circle-more.svg';
      case SailSVGAsset.iconFileMinus:
        return 'assets/svgs/file-minus.svg';
      case SailSVGAsset.iconSquarePower:
        return 'assets/svgs/square-power.svg';
      case SailSVGAsset.iconSquareChevronUp:
        return 'assets/svgs/square-chevron-up.svg';
      case SailSVGAsset.iconIconTabPeg:
        return 'assets/svgs/icon_tab_peg.svg';
      case SailSVGAsset.iconAlignHorizontalJustifyStart:
        return 'assets/svgs/align-horizontal-justify-start.svg';
      case SailSVGAsset.iconCopyPlus:
        return 'assets/svgs/copy-plus.svg';
      case SailSVGAsset.iconTimerOff:
        return 'assets/svgs/timer-off.svg';
      case SailSVGAsset.iconFolderCheck:
        return 'assets/svgs/folder-check.svg';
      case SailSVGAsset.iconBadgeJapaneseYen:
        return 'assets/svgs/badge-japanese-yen.svg';
      case SailSVGAsset.iconArrowUpFromLine:
        return 'assets/svgs/arrow-up-from-line.svg';
      case SailSVGAsset.iconFlipVertical2:
        return 'assets/svgs/flip-vertical-2.svg';
      case SailSVGAsset.iconAnnoyed:
        return 'assets/svgs/annoyed.svg';
      case SailSVGAsset.iconLigature:
        return 'assets/svgs/ligature.svg';
      case SailSVGAsset.iconMessageSquareWarning:
        return 'assets/svgs/message-square-warning.svg';
      case SailSVGAsset.iconLayoutGrid:
        return 'assets/svgs/layout-grid.svg';
      case SailSVGAsset.iconRockingChair:
        return 'assets/svgs/rocking-chair.svg';
      case SailSVGAsset.iconChevronsUpDown:
        return 'assets/svgs/chevrons-up-down.svg';
      case SailSVGAsset.iconBadgeMinus:
        return 'assets/svgs/badge-minus.svg';
      case SailSVGAsset.iconCalendarOff:
        return 'assets/svgs/calendar-off.svg';
      case SailSVGAsset.iconCircle:
        return 'assets/svgs/circle.svg';
      case SailSVGAsset.iconAirVent:
        return 'assets/svgs/air-vent.svg';
      case SailSVGAsset.iconPhoneMissed:
        return 'assets/svgs/phone-missed.svg';
      case SailSVGAsset.iconScale3d:
        return 'assets/svgs/scale-3d.svg';
      case SailSVGAsset.iconCornerLeftUp:
        return 'assets/svgs/corner-left-up.svg';
      case SailSVGAsset.iconMilk:
        return 'assets/svgs/milk.svg';
      case SailSVGAsset.iconClipboardPen:
        return 'assets/svgs/clipboard-pen.svg';
      case SailSVGAsset.iconFileUp:
        return 'assets/svgs/file-up.svg';
      case SailSVGAsset.iconCopyright:
        return 'assets/svgs/copyright.svg';
      case SailSVGAsset.iconPictureInPicture:
        return 'assets/svgs/picture-in-picture.svg';
      case SailSVGAsset.iconVault:
        return 'assets/svgs/vault.svg';
      case SailSVGAsset.iconCirclePower:
        return 'assets/svgs/circle-power.svg';
      case SailSVGAsset.iconMailbox:
        return 'assets/svgs/mailbox.svg';
      case SailSVGAsset.iconGitlab:
        return 'assets/svgs/gitlab.svg';
      case SailSVGAsset.iconMusic:
        return 'assets/svgs/music.svg';
      case SailSVGAsset.iconFileBarChart2:
        return 'assets/svgs/file-bar-chart-2.svg';
      case SailSVGAsset.iconRectangleEllipsis:
        return 'assets/svgs/rectangle-ellipsis.svg';
      case SailSVGAsset.iconSmartphone:
        return 'assets/svgs/smartphone.svg';
      case SailSVGAsset.iconFileSymlink:
        return 'assets/svgs/file-symlink.svg';
      case SailSVGAsset.iconAlarmClockCheck:
        return 'assets/svgs/alarm-clock-check.svg';
      case SailSVGAsset.iconIconLearn:
        return 'assets/svgs/icon_learn.svg';
      case SailSVGAsset.iconCandyOff:
        return 'assets/svgs/candy-off.svg';
      case SailSVGAsset.iconCircuitBoard:
        return 'assets/svgs/circuit-board.svg';
      case SailSVGAsset.iconFolderTree:
        return 'assets/svgs/folder-tree.svg';
      case SailSVGAsset.iconEqual:
        return 'assets/svgs/equal.svg';
      case SailSVGAsset.iconRecycle:
        return 'assets/svgs/recycle.svg';
      case SailSVGAsset.iconArrowUpLeft:
        return 'assets/svgs/arrow-up-left.svg';
      case SailSVGAsset.iconClipboardType:
        return 'assets/svgs/clipboard-type.svg';
      case SailSVGAsset.iconLibrary:
        return 'assets/svgs/library.svg';
      case SailSVGAsset.iconPanelTopClose:
        return 'assets/svgs/panel-top-close.svg';
      case SailSVGAsset.iconIconTabSidechainSend:
        return 'assets/svgs/icon_tab_sidechain_send.svg';
      case SailSVGAsset.iconFilePieChart:
        return 'assets/svgs/file-pie-chart.svg';
      case SailSVGAsset.iconSquareArrowDown:
        return 'assets/svgs/square-arrow-down.svg';
      case SailSVGAsset.iconListPlus:
        return 'assets/svgs/list-plus.svg';
      case SailSVGAsset.iconChevronDown:
        return 'assets/svgs/chevron-down.svg';
      case SailSVGAsset.iconBackpack:
        return 'assets/svgs/backpack.svg';
      case SailSVGAsset.iconCalendarCheck2:
        return 'assets/svgs/calendar-check-2.svg';
      case SailSVGAsset.iconHeading:
        return 'assets/svgs/heading.svg';
      case SailSVGAsset.iconHexagon:
        return 'assets/svgs/hexagon.svg';
      case SailSVGAsset.iconStrikethrough:
        return 'assets/svgs/strikethrough.svg';
      case SailSVGAsset.iconCalendarFold:
        return 'assets/svgs/calendar-fold.svg';
      case SailSVGAsset.iconMessageSquareHeart:
        return 'assets/svgs/message-square-heart.svg';
      case SailSVGAsset.iconBird:
        return 'assets/svgs/bird.svg';
      case SailSVGAsset.iconBotMessageSquare:
        return 'assets/svgs/bot-message-square.svg';
      case SailSVGAsset.iconSunMedium:
        return 'assets/svgs/sun-medium.svg';
      case SailSVGAsset.iconBadgeInfo:
        return 'assets/svgs/badge-info.svg';
      case SailSVGAsset.iconShieldPlus:
        return 'assets/svgs/shield-plus.svg';
      case SailSVGAsset.iconBookMarked:
        return 'assets/svgs/book-marked.svg';
      case SailSVGAsset.iconCreativeCommons:
        return 'assets/svgs/creative-commons.svg';
      case SailSVGAsset.iconShirt:
        return 'assets/svgs/shirt.svg';
      case SailSVGAsset.iconDock:
        return 'assets/svgs/dock.svg';
      case SailSVGAsset.iconSignpost:
        return 'assets/svgs/signpost.svg';
      case SailSVGAsset.iconDoorClosed:
        return 'assets/svgs/door-closed.svg';
      case SailSVGAsset.iconGithub:
        return 'assets/svgs/github.svg';
      case SailSVGAsset.iconFoldHorizontal:
        return 'assets/svgs/fold-horizontal.svg';
      case SailSVGAsset.iconNfc:
        return 'assets/svgs/nfc.svg';
      case SailSVGAsset.iconClipboardPaste:
        return 'assets/svgs/clipboard-paste.svg';
      case SailSVGAsset.iconCone:
        return 'assets/svgs/cone.svg';
      case SailSVGAsset.iconCookingPot:
        return 'assets/svgs/cooking-pot.svg';
      case SailSVGAsset.iconProportions:
        return 'assets/svgs/proportions.svg';
      case SailSVGAsset.iconBringToFront:
        return 'assets/svgs/bring-to-front.svg';
      case SailSVGAsset.iconUsb:
        return 'assets/svgs/usb.svg';
      case SailSVGAsset.iconSeparatorVertical:
        return 'assets/svgs/separator-vertical.svg';
      case SailSVGAsset.iconBoxSelect:
        return 'assets/svgs/box-select.svg';
      case SailSVGAsset.iconHardHat:
        return 'assets/svgs/hard-hat.svg';
      case SailSVGAsset.iconCakeSlice:
        return 'assets/svgs/cake-slice.svg';
      case SailSVGAsset.iconSunMoon:
        return 'assets/svgs/sun-moon.svg';
      case SailSVGAsset.iconTicket:
        return 'assets/svgs/ticket.svg';
      case SailSVGAsset.iconCalendarPlus2:
        return 'assets/svgs/calendar-plus-2.svg';
      case SailSVGAsset.iconCaseLower:
        return 'assets/svgs/case-lower.svg';
      case SailSVGAsset.iconLayoutTemplate:
        return 'assets/svgs/layout-template.svg';
      case SailSVGAsset.iconPanelRightOpen:
        return 'assets/svgs/panel-right-open.svg';
      case SailSVGAsset.iconBrackets:
        return 'assets/svgs/brackets.svg';
      case SailSVGAsset.iconStarOff:
        return 'assets/svgs/star-off.svg';
      case SailSVGAsset.iconShrink:
        return 'assets/svgs/shrink.svg';
      case SailSVGAsset.iconChurch:
        return 'assets/svgs/church.svg';
      case SailSVGAsset.iconCirclePercent:
        return 'assets/svgs/circle-percent.svg';
      case SailSVGAsset.iconCrop:
        return 'assets/svgs/crop.svg';
      case SailSVGAsset.iconFlaskRound:
        return 'assets/svgs/flask-round.svg';
      case SailSVGAsset.iconIconTerminal:
        return 'assets/svgs/icon_terminal.svg';
      case SailSVGAsset.iconCookie:
        return 'assets/svgs/cookie.svg';
      case SailSVGAsset.iconRedo2:
        return 'assets/svgs/redo-2.svg';
      case SailSVGAsset.iconCircleSlash2:
        return 'assets/svgs/circle-slash-2.svg';
      case SailSVGAsset.iconTag:
        return 'assets/svgs/tag.svg';
      case SailSVGAsset.iconBookCheck:
        return 'assets/svgs/book-check.svg';
      case SailSVGAsset.iconIconTabShieldDeshield:
        return 'assets/svgs/icon_tab_shield_deshield.svg';
      case SailSVGAsset.iconOctagonPause:
        return 'assets/svgs/octagon-pause.svg';
      case SailSVGAsset.iconCupSoda:
        return 'assets/svgs/cup-soda.svg';
      case SailSVGAsset.iconOption:
        return 'assets/svgs/option.svg';
      case SailSVGAsset.iconSparkle:
        return 'assets/svgs/sparkle.svg';
      case SailSVGAsset.iconBriefcase:
        return 'assets/svgs/briefcase.svg';
      case SailSVGAsset.iconCircleChevronDown:
        return 'assets/svgs/circle-chevron-down.svg';
      case SailSVGAsset.iconPresentation:
        return 'assets/svgs/presentation.svg';
      case SailSVGAsset.iconSquareSigma:
        return 'assets/svgs/square-sigma.svg';
      case SailSVGAsset.iconRotateCw:
        return 'assets/svgs/rotate-cw.svg';
      case SailSVGAsset.iconFileAudio:
        return 'assets/svgs/file-audio.svg';
      case SailSVGAsset.iconEllipsisVertical:
        return 'assets/svgs/ellipsis-vertical.svg';
      case SailSVGAsset.iconBadgePlus:
        return 'assets/svgs/badge-plus.svg';
      case SailSVGAsset.iconScreenShareOff:
        return 'assets/svgs/screen-share-off.svg';
      case SailSVGAsset.iconSquarePlay:
        return 'assets/svgs/square-play.svg';
      case SailSVGAsset.iconAlignHorizontalDistributeEnd:
        return 'assets/svgs/align-horizontal-distribute-end.svg';
      case SailSVGAsset.iconFileClock:
        return 'assets/svgs/file-clock.svg';
      case SailSVGAsset.iconCalendarSearch:
        return 'assets/svgs/calendar-search.svg';
      case SailSVGAsset.iconImageDown:
        return 'assets/svgs/image-down.svg';
      case SailSVGAsset.iconSwatchBook:
        return 'assets/svgs/swatch-book.svg';
      case SailSVGAsset.iconRadius:
        return 'assets/svgs/radius.svg';
      case SailSVGAsset.iconFolderSync:
        return 'assets/svgs/folder-sync.svg';
      case SailSVGAsset.iconPanelsTopLeft:
        return 'assets/svgs/panels-top-left.svg';
      case SailSVGAsset.iconHeadset:
        return 'assets/svgs/headset.svg';
      case SailSVGAsset.iconCircleEqual:
        return 'assets/svgs/circle-equal.svg';
      case SailSVGAsset.iconDessert:
        return 'assets/svgs/dessert.svg';
      case SailSVGAsset.iconCarrot:
        return 'assets/svgs/carrot.svg';
      case SailSVGAsset.iconReceiptEuro:
        return 'assets/svgs/receipt-euro.svg';
      case SailSVGAsset.iconMap:
        return 'assets/svgs/map.svg';
      case SailSVGAsset.iconCheckCheck:
        return 'assets/svgs/check-check.svg';
      case SailSVGAsset.iconInbox:
        return 'assets/svgs/inbox.svg';
      case SailSVGAsset.iconCircleAlert:
        return 'assets/svgs/circle-alert.svg';
      case SailSVGAsset.iconTvMinimal:
        return 'assets/svgs/tv-minimal.svg';
      case SailSVGAsset.iconAlignJustify:
        return 'assets/svgs/align-justify.svg';
      case SailSVGAsset.iconIconGlobe:
        return 'assets/svgs/icon_globe.svg';
      case SailSVGAsset.iconPower:
        return 'assets/svgs/power.svg';
      case SailSVGAsset.iconALargeSmall:
        return 'assets/svgs/a-large-small.svg';
      case SailSVGAsset.iconTentTree:
        return 'assets/svgs/tent-tree.svg';
      case SailSVGAsset.iconDatabase:
        return 'assets/svgs/database.svg';
      case SailSVGAsset.iconCaptions:
        return 'assets/svgs/captions.svg';
      case SailSVGAsset.iconMartini:
        return 'assets/svgs/martini.svg';
      case SailSVGAsset.iconArrowUpToLine:
        return 'assets/svgs/arrow-up-to-line.svg';
      case SailSVGAsset.iconMonitorDown:
        return 'assets/svgs/monitor-down.svg';
      case SailSVGAsset.iconBadgeIndianRupee:
        return 'assets/svgs/badge-indian-rupee.svg';
      case SailSVGAsset.iconCameraOff:
        return 'assets/svgs/camera-off.svg';
      case SailSVGAsset.iconFuel:
        return 'assets/svgs/fuel.svg';
      case SailSVGAsset.iconSatelliteDish:
        return 'assets/svgs/satellite-dish.svg';
      case SailSVGAsset.iconBike:
        return 'assets/svgs/bike.svg';
      case SailSVGAsset.iconSwords:
        return 'assets/svgs/swords.svg';
      case SailSVGAsset.iconMessageSquareOff:
        return 'assets/svgs/message-square-off.svg';
      case SailSVGAsset.iconScanText:
        return 'assets/svgs/scan-text.svg';
      case SailSVGAsset.iconArrowDownZA:
        return 'assets/svgs/arrow-down-z-a.svg';
      case SailSVGAsset.iconRat:
        return 'assets/svgs/rat.svg';
      case SailSVGAsset.iconTornado:
        return 'assets/svgs/tornado.svg';
      case SailSVGAsset.iconToggleLeft:
        return 'assets/svgs/toggle-left.svg';
      case SailSVGAsset.iconFile:
        return 'assets/svgs/file.svg';
      case SailSVGAsset.iconPuzzle:
        return 'assets/svgs/puzzle.svg';
      case SailSVGAsset.iconAlignVerticalDistributeCenter:
        return 'assets/svgs/align-vertical-distribute-center.svg';
      case SailSVGAsset.iconSignal:
        return 'assets/svgs/signal.svg';
      case SailSVGAsset.iconEggOff:
        return 'assets/svgs/egg-off.svg';
      case SailSVGAsset.iconArrowUp10:
        return 'assets/svgs/arrow-up-1-0.svg';
      case SailSVGAsset.iconFileAudio2:
        return 'assets/svgs/file-audio-2.svg';
      case SailSVGAsset.iconBaseline:
        return 'assets/svgs/baseline.svg';
      case SailSVGAsset.iconVibrateOff:
        return 'assets/svgs/vibrate-off.svg';
      case SailSVGAsset.iconGlassWater:
        return 'assets/svgs/glass-water.svg';
      case SailSVGAsset.iconBrain:
        return 'assets/svgs/brain.svg';
      case SailSVGAsset.iconFiles:
        return 'assets/svgs/files.svg';
      case SailSVGAsset.iconTorus:
        return 'assets/svgs/torus.svg';
      case SailSVGAsset.iconScanSearch:
        return 'assets/svgs/scan-search.svg';
      case SailSVGAsset.iconSquareDashedBottomCode:
        return 'assets/svgs/square-dashed-bottom-code.svg';
      case SailSVGAsset.iconMessageCircle:
        return 'assets/svgs/message-circle.svg';
      case SailSVGAsset.iconMessageSquareDot:
        return 'assets/svgs/message-square-dot.svg';
      case SailSVGAsset.iconReceiptJapaneseYen:
        return 'assets/svgs/receipt-japanese-yen.svg';
      case SailSVGAsset.iconVoicemail:
        return 'assets/svgs/voicemail.svg';
      case SailSVGAsset.iconMessagesSquare:
        return 'assets/svgs/messages-square.svg';
      case SailSVGAsset.iconShipWheel:
        return 'assets/svgs/ship-wheel.svg';
      case SailSVGAsset.iconMessageSquareQuote:
        return 'assets/svgs/message-square-quote.svg';
      case SailSVGAsset.iconContrast:
        return 'assets/svgs/contrast.svg';
      case SailSVGAsset.iconCuboid:
        return 'assets/svgs/cuboid.svg';
      case SailSVGAsset.iconAlarmClockPlus:
        return 'assets/svgs/alarm-clock-plus.svg';
      case SailSVGAsset.iconMonitorPause:
        return 'assets/svgs/monitor-pause.svg';
      case SailSVGAsset.iconFileVideo2:
        return 'assets/svgs/file-video-2.svg';
      case SailSVGAsset.iconArchiveX:
        return 'assets/svgs/archive-x.svg';
      case SailSVGAsset.iconMoveDiagonal:
        return 'assets/svgs/move-diagonal.svg';
      case SailSVGAsset.iconFileScan:
        return 'assets/svgs/file-scan.svg';
      case SailSVGAsset.iconArrowUpWideNarrow:
        return 'assets/svgs/arrow-up-wide-narrow.svg';
      case SailSVGAsset.iconMove:
        return 'assets/svgs/move.svg';
      case SailSVGAsset.iconMaximize:
        return 'assets/svgs/maximize.svg';
      case SailSVGAsset.iconBetweenVerticalStart:
        return 'assets/svgs/between-vertical-start.svg';
      case SailSVGAsset.iconLaptopMinimal:
        return 'assets/svgs/laptop-minimal.svg';
      case SailSVGAsset.iconRadar:
        return 'assets/svgs/radar.svg';
      case SailSVGAsset.iconIconPending:
        return 'assets/svgs/icon_pending.svg';
      case SailSVGAsset.iconSparkles:
        return 'assets/svgs/sparkles.svg';
      case SailSVGAsset.iconLockKeyhole:
        return 'assets/svgs/lock-keyhole.svg';
      case SailSVGAsset.iconOctagonX:
        return 'assets/svgs/octagon-x.svg';
      case SailSVGAsset.iconFolderRoot:
        return 'assets/svgs/folder-root.svg';
      case SailSVGAsset.iconChevronUp:
        return 'assets/svgs/chevron-up.svg';
      case SailSVGAsset.iconCircleHelp:
        return 'assets/svgs/circle-help.svg';
      case SailSVGAsset.iconSquarePercent:
        return 'assets/svgs/square-percent.svg';
      case SailSVGAsset.iconHaze:
        return 'assets/svgs/haze.svg';
      case SailSVGAsset.iconFolderOutput:
        return 'assets/svgs/folder-output.svg';
      case SailSVGAsset.iconFolderSymlink:
        return 'assets/svgs/folder-symlink.svg';
      case SailSVGAsset.iconFileBadge2:
        return 'assets/svgs/file-badge-2.svg';
      case SailSVGAsset.iconVibrate:
        return 'assets/svgs/vibrate.svg';
      case SailSVGAsset.iconLaugh:
        return 'assets/svgs/laugh.svg';
      case SailSVGAsset.iconScanEye:
        return 'assets/svgs/scan-eye.svg';
      case SailSVGAsset.iconSpade:
        return 'assets/svgs/spade.svg';
      case SailSVGAsset.iconCloudRainWind:
        return 'assets/svgs/cloud-rain-wind.svg';
      case SailSVGAsset.iconSlidersVertical:
        return 'assets/svgs/sliders-vertical.svg';
      case SailSVGAsset.iconIconWallet:
        return 'assets/svgs/icon_wallet.svg';
      case SailSVGAsset.iconUndo2:
        return 'assets/svgs/undo-2.svg';
      case SailSVGAsset.iconFileVideo:
        return 'assets/svgs/file-video.svg';
      case SailSVGAsset.iconStepBack:
        return 'assets/svgs/step-back.svg';
      case SailSVGAsset.iconFlaskConicalOff:
        return 'assets/svgs/flask-conical-off.svg';
      case SailSVGAsset.iconArrowDownLeft:
        return 'assets/svgs/arrow-down-left.svg';
      case SailSVGAsset.iconFileText:
        return 'assets/svgs/file-text.svg';
      case SailSVGAsset.iconFileStack:
        return 'assets/svgs/file-stack.svg';
      case SailSVGAsset.iconFolderOpen:
        return 'assets/svgs/folder-open.svg';
      case SailSVGAsset.iconPackageMinus:
        return 'assets/svgs/package-minus.svg';
      case SailSVGAsset.iconDroplet:
        return 'assets/svgs/droplet.svg';
      case SailSVGAsset.iconWholeWord:
        return 'assets/svgs/whole-word.svg';
      case SailSVGAsset.iconPaintRoller:
        return 'assets/svgs/paint-roller.svg';
      case SailSVGAsset.iconZapOff:
        return 'assets/svgs/zap-off.svg';
      case SailSVGAsset.iconSquareKanban:
        return 'assets/svgs/square-kanban.svg';
      case SailSVGAsset.iconKeyboard:
        return 'assets/svgs/keyboard.svg';
      case SailSVGAsset.iconX:
        return 'assets/svgs/x.svg';
      case SailSVGAsset.iconChevronsRightLeft:
        return 'assets/svgs/chevrons-right-left.svg';
      case SailSVGAsset.iconJoystick:
        return 'assets/svgs/joystick.svg';
      case SailSVGAsset.iconCigarette:
        return 'assets/svgs/cigarette.svg';
      case SailSVGAsset.iconBath:
        return 'assets/svgs/bath.svg';
      case SailSVGAsset.iconBarChart:
        return 'assets/svgs/bar-chart.svg';
      case SailSVGAsset.iconQrCode:
        return 'assets/svgs/qr-code.svg';
      case SailSVGAsset.iconDot:
        return 'assets/svgs/dot.svg';
      case SailSVGAsset.iconIceCreamCone:
        return 'assets/svgs/ice-cream-cone.svg';
      case SailSVGAsset.iconLanguages:
        return 'assets/svgs/languages.svg';
      case SailSVGAsset.iconAmpersands:
        return 'assets/svgs/ampersands.svg';
      case SailSVGAsset.iconArrowLeftFromLine:
        return 'assets/svgs/arrow-left-from-line.svg';
      case SailSVGAsset.iconBellMinus:
        return 'assets/svgs/bell-minus.svg';
      case SailSVGAsset.iconFileCog:
        return 'assets/svgs/file-cog.svg';
      case SailSVGAsset.iconWheat:
        return 'assets/svgs/wheat.svg';
      case SailSVGAsset.iconCableCar:
        return 'assets/svgs/cable-car.svg';
      case SailSVGAsset.iconArrowUpNarrowWide:
        return 'assets/svgs/arrow-up-narrow-wide.svg';
      case SailSVGAsset.iconLock:
        return 'assets/svgs/lock.svg';
      case SailSVGAsset.iconDice2:
        return 'assets/svgs/dice-2.svg';
      case SailSVGAsset.iconLogIn:
        return 'assets/svgs/log-in.svg';
      case SailSVGAsset.iconSquircle:
        return 'assets/svgs/squircle.svg';
      case SailSVGAsset.iconCloudUpload:
        return 'assets/svgs/cloud-upload.svg';
      case SailSVGAsset.iconShieldEllipsis:
        return 'assets/svgs/shield-ellipsis.svg';
      case SailSVGAsset.iconBan:
        return 'assets/svgs/ban.svg';
      case SailSVGAsset.iconSmartphoneNfc:
        return 'assets/svgs/smartphone-nfc.svg';
      case SailSVGAsset.iconListVideo:
        return 'assets/svgs/list-video.svg';
      case SailSVGAsset.iconTextSelect:
        return 'assets/svgs/text-select.svg';
      case SailSVGAsset.iconShoppingBag:
        return 'assets/svgs/shopping-bag.svg';
      case SailSVGAsset.iconDivide:
        return 'assets/svgs/divide.svg';
      case SailSVGAsset.iconPiggyBank:
        return 'assets/svgs/piggy-bank.svg';
      case SailSVGAsset.iconBatteryWarning:
        return 'assets/svgs/battery-warning.svg';
      case SailSVGAsset.iconWalletMinimal:
        return 'assets/svgs/wallet-minimal.svg';
      case SailSVGAsset.iconCircleDollarSign:
        return 'assets/svgs/circle-dollar-sign.svg';
      case SailSVGAsset.iconMilkOff:
        return 'assets/svgs/milk-off.svg';
      case SailSVGAsset.iconSquareParking:
        return 'assets/svgs/square-parking.svg';
      case SailSVGAsset.iconRefreshCcwDot:
        return 'assets/svgs/refresh-ccw-dot.svg';
      case SailSVGAsset.iconTally2:
        return 'assets/svgs/tally-2.svg';
      case SailSVGAsset.iconShell:
        return 'assets/svgs/shell.svg';
      case SailSVGAsset.iconRepeat2:
        return 'assets/svgs/repeat-2.svg';
      case SailSVGAsset.iconPilcrow:
        return 'assets/svgs/pilcrow.svg';
      case SailSVGAsset.iconCircleDotDashed:
        return 'assets/svgs/circle-dot-dashed.svg';
      case SailSVGAsset.iconMailQuestion:
        return 'assets/svgs/mail-question.svg';
      case SailSVGAsset.iconCloudDrizzle:
        return 'assets/svgs/cloud-drizzle.svg';
      case SailSVGAsset.iconCopyMinus:
        return 'assets/svgs/copy-minus.svg';
      case SailSVGAsset.iconSpline:
        return 'assets/svgs/spline.svg';
      case SailSVGAsset.iconRefreshCw:
        return 'assets/svgs/refresh-cw.svg';
      case SailSVGAsset.iconIconCopy:
        return 'assets/svgs/icon_copy.svg';
      case SailSVGAsset.iconPlane:
        return 'assets/svgs/plane.svg';
      case SailSVGAsset.iconAlignVerticalSpaceBetween:
        return 'assets/svgs/align-vertical-space-between.svg';
      case SailSVGAsset.iconChevronRight:
        return 'assets/svgs/chevron-right.svg';
      case SailSVGAsset.iconTally3:
        return 'assets/svgs/tally-3.svg';
      case SailSVGAsset.iconClipboard:
        return 'assets/svgs/clipboard.svg';
      case SailSVGAsset.iconEqualNot:
        return 'assets/svgs/equal-not.svg';
      case SailSVGAsset.iconPackage:
        return 'assets/svgs/package.svg';
      case SailSVGAsset.iconInstagram:
        return 'assets/svgs/instagram.svg';
      case SailSVGAsset.iconMailWarning:
        return 'assets/svgs/mail-warning.svg';
      case SailSVGAsset.iconEuro:
        return 'assets/svgs/euro.svg';
      case SailSVGAsset.iconLink:
        return 'assets/svgs/link.svg';
      case SailSVGAsset.iconSquareChevronLeft:
        return 'assets/svgs/square-chevron-left.svg';
      case SailSVGAsset.iconGlobeLock:
        return 'assets/svgs/globe-lock.svg';
      case SailSVGAsset.iconDice3:
        return 'assets/svgs/dice-3.svg';
      case SailSVGAsset.iconHandPlatter:
        return 'assets/svgs/hand-platter.svg';
      case SailSVGAsset.iconVideoOff:
        return 'assets/svgs/video-off.svg';
      case SailSVGAsset.iconUserRoundPlus:
        return 'assets/svgs/user-round-plus.svg';
      case SailSVGAsset.iconKey:
        return 'assets/svgs/key.svg';
      case SailSVGAsset.iconSquareActivity:
        return 'assets/svgs/square-activity.svg';
      case SailSVGAsset.iconShrub:
        return 'assets/svgs/shrub.svg';
      case SailSVGAsset.iconSailboat:
        return 'assets/svgs/sailboat.svg';
      case SailSVGAsset.iconFileX2:
        return 'assets/svgs/file-x-2.svg';
      case SailSVGAsset.iconSquareSlash:
        return 'assets/svgs/square-slash.svg';
      case SailSVGAsset.iconBrainCog:
        return 'assets/svgs/brain-cog.svg';
      case SailSVGAsset.iconMeh:
        return 'assets/svgs/meh.svg';
      case SailSVGAsset.iconSlidersHorizontal:
        return 'assets/svgs/sliders-horizontal.svg';
      case SailSVGAsset.iconDoorOpen:
        return 'assets/svgs/door-open.svg';
      case SailSVGAsset.iconCornerDownRight:
        return 'assets/svgs/corner-down-right.svg';
      case SailSVGAsset.iconBeaker:
        return 'assets/svgs/beaker.svg';
      case SailSVGAsset.iconListTodo:
        return 'assets/svgs/list-todo.svg';
      case SailSVGAsset.iconCloudSun:
        return 'assets/svgs/cloud-sun.svg';
      case SailSVGAsset.iconIconDownload:
        return 'assets/svgs/icon_download.svg';
      case SailSVGAsset.iconArrowRight:
        return 'assets/svgs/arrow-right.svg';
      case SailSVGAsset.iconStore:
        return 'assets/svgs/store.svg';
      case SailSVGAsset.iconAntenna:
        return 'assets/svgs/antenna.svg';
      case SailSVGAsset.iconChevronFirst:
        return 'assets/svgs/chevron-first.svg';
      case SailSVGAsset.iconWheatOff:
        return 'assets/svgs/wheat-off.svg';
      case SailSVGAsset.iconAperture:
        return 'assets/svgs/aperture.svg';
      case SailSVGAsset.iconCalendarPlus:
        return 'assets/svgs/calendar-plus.svg';
      case SailSVGAsset.iconBrush:
        return 'assets/svgs/brush.svg';
      case SailSVGAsset.iconThermometerSnowflake:
        return 'assets/svgs/thermometer-snowflake.svg';
      case SailSVGAsset.iconClover:
        return 'assets/svgs/clover.svg';
      case SailSVGAsset.iconConciergeBell:
        return 'assets/svgs/concierge-bell.svg';
      case SailSVGAsset.iconLogOut:
        return 'assets/svgs/log-out.svg';
      case SailSVGAsset.iconUnfoldHorizontal:
        return 'assets/svgs/unfold-horizontal.svg';
      case SailSVGAsset.iconFileSpreadsheet:
        return 'assets/svgs/file-spreadsheet.svg';
      case SailSVGAsset.iconSquareRadical:
        return 'assets/svgs/square-radical.svg';
      case SailSVGAsset.iconCirclePlay:
        return 'assets/svgs/circle-play.svg';
      case SailSVGAsset.iconSquareArrowUp:
        return 'assets/svgs/square-arrow-up.svg';
      case SailSVGAsset.iconFileCode2:
        return 'assets/svgs/file-code-2.svg';
      case SailSVGAsset.iconTelescope:
        return 'assets/svgs/telescope.svg';
      case SailSVGAsset.iconShip:
        return 'assets/svgs/ship.svg';
      case SailSVGAsset.iconEarOff:
        return 'assets/svgs/ear-off.svg';
      case SailSVGAsset.iconWorm:
        return 'assets/svgs/worm.svg';
      case SailSVGAsset.iconWallpaper:
        return 'assets/svgs/wallpaper.svg';
      case SailSVGAsset.iconAmbulance:
        return 'assets/svgs/ambulance.svg';
      case SailSVGAsset.iconSpace:
        return 'assets/svgs/space.svg';
      case SailSVGAsset.iconFileInput:
        return 'assets/svgs/file-input.svg';
      case SailSVGAsset.iconBarChart2:
        return 'assets/svgs/bar-chart-2.svg';
      case SailSVGAsset.iconBookDashed:
        return 'assets/svgs/book-dashed.svg';
      case SailSVGAsset.iconStretchVertical:
        return 'assets/svgs/stretch-vertical.svg';
      case SailSVGAsset.iconCalendarCheck:
        return 'assets/svgs/calendar-check.svg';
      case SailSVGAsset.iconDiff:
        return 'assets/svgs/diff.svg';
      case SailSVGAsset.iconShowerHead:
        return 'assets/svgs/shower-head.svg';
      case SailSVGAsset.iconSquarePen:
        return 'assets/svgs/square-pen.svg';
      case SailSVGAsset.iconArrowDownUp:
        return 'assets/svgs/arrow-down-up.svg';
      case SailSVGAsset.iconGitPullRequest:
        return 'assets/svgs/git-pull-request.svg';
      case SailSVGAsset.iconMinimize:
        return 'assets/svgs/minimize.svg';
      case SailSVGAsset.iconGroup:
        return 'assets/svgs/group.svg';
      case SailSVGAsset.iconSettings:
        return 'assets/svgs/settings.svg';
      case SailSVGAsset.iconCloudSnow:
        return 'assets/svgs/cloud-snow.svg';
      case SailSVGAsset.iconNotepadTextDashed:
        return 'assets/svgs/notepad-text-dashed.svg';
      case SailSVGAsset.iconCalendarX2:
        return 'assets/svgs/calendar-x-2.svg';
      case SailSVGAsset.iconCassetteTape:
        return 'assets/svgs/cassette-tape.svg';
      case SailSVGAsset.iconThumbsDown:
        return 'assets/svgs/thumbs-down.svg';
      case SailSVGAsset.iconDice1:
        return 'assets/svgs/dice-1.svg';
      case SailSVGAsset.iconMoveDownLeft:
        return 'assets/svgs/move-down-left.svg';
      case SailSVGAsset.iconVote:
        return 'assets/svgs/vote.svg';
      case SailSVGAsset.iconBotOff:
        return 'assets/svgs/bot-off.svg';
      case SailSVGAsset.iconType:
        return 'assets/svgs/type.svg';
      case SailSVGAsset.iconSquareDashedMousePointer:
        return 'assets/svgs/square-dashed-mouse-pointer.svg';
      case SailSVGAsset.iconSquareMenu:
        return 'assets/svgs/square-menu.svg';
      case SailSVGAsset.iconMousePointerClick:
        return 'assets/svgs/mouse-pointer-click.svg';
      case SailSVGAsset.iconRegex:
        return 'assets/svgs/regex.svg';
      case SailSVGAsset.iconSquareCheckBig:
        return 'assets/svgs/square-check-big.svg';
      case SailSVGAsset.iconIconQuestion:
        return 'assets/svgs/icon_question.svg';
      case SailSVGAsset.iconLoaderCircle:
        return 'assets/svgs/loader-circle.svg';
      case SailSVGAsset.iconPopsicle:
        return 'assets/svgs/popsicle.svg';
      case SailSVGAsset.iconLampFloor:
        return 'assets/svgs/lamp-floor.svg';
      case SailSVGAsset.iconUtensils:
        return 'assets/svgs/utensils.svg';
      case SailSVGAsset.iconArchive:
        return 'assets/svgs/archive.svg';
      case SailSVGAsset.iconIconSend:
        return 'assets/svgs/icon_send.svg';
      case SailSVGAsset.iconBean:
        return 'assets/svgs/bean.svg';
      case SailSVGAsset.iconPanelsRightBottom:
        return 'assets/svgs/panels-right-bottom.svg';
      case SailSVGAsset.iconMessageSquareText:
        return 'assets/svgs/message-square-text.svg';
      case SailSVGAsset.iconRefreshCwOff:
        return 'assets/svgs/refresh-cw-off.svg';
      case SailSVGAsset.iconPhoneOutgoing:
        return 'assets/svgs/phone-outgoing.svg';
      case SailSVGAsset.iconTally1:
        return 'assets/svgs/tally-1.svg';
      case SailSVGAsset.iconArrowUpFromDot:
        return 'assets/svgs/arrow-up-from-dot.svg';
      case SailSVGAsset.iconCandy:
        return 'assets/svgs/candy.svg';
      case SailSVGAsset.iconPocket:
        return 'assets/svgs/pocket.svg';
      case SailSVGAsset.iconRepeat1:
        return 'assets/svgs/repeat-1.svg';
      case SailSVGAsset.iconMagnet:
        return 'assets/svgs/magnet.svg';
      case SailSVGAsset.iconCircleParking:
        return 'assets/svgs/circle-parking.svg';
      case SailSVGAsset.iconMail:
        return 'assets/svgs/mail.svg';
      case SailSVGAsset.iconSchool:
        return 'assets/svgs/school.svg';
      case SailSVGAsset.iconArrowBigRight:
        return 'assets/svgs/arrow-big-right.svg';
      case SailSVGAsset.iconShield:
        return 'assets/svgs/shield.svg';
      case SailSVGAsset.iconDownload:
        return 'assets/svgs/download.svg';
      case SailSVGAsset.iconKanban:
        return 'assets/svgs/kanban.svg';
      case SailSVGAsset.iconFileVolume:
        return 'assets/svgs/file-volume.svg';
      case SailSVGAsset.iconGalleryVerticalEnd:
        return 'assets/svgs/gallery-vertical-end.svg';
      case SailSVGAsset.iconFileWarning:
        return 'assets/svgs/file-warning.svg';
      case SailSVGAsset.iconDiscAlbum:
        return 'assets/svgs/disc-album.svg';
      case SailSVGAsset.iconPin:
        return 'assets/svgs/pin.svg';
      case SailSVGAsset.iconArrowUpAZ:
        return 'assets/svgs/arrow-up-a-z.svg';
      case SailSVGAsset.iconSquareCheck:
        return 'assets/svgs/square-check.svg';
      case SailSVGAsset.iconBarChartHorizontalBig:
        return 'assets/svgs/bar-chart-horizontal-big.svg';
      case SailSVGAsset.iconImport:
        return 'assets/svgs/import.svg';
      case SailSVGAsset.iconWebcam:
        return 'assets/svgs/webcam.svg';
      case SailSVGAsset.iconIconSearch:
        return 'assets/svgs/icon_search.svg';
      case SailSVGAsset.iconPhoneForwarded:
        return 'assets/svgs/phone-forwarded.svg';
      case SailSVGAsset.iconBellPlus:
        return 'assets/svgs/bell-plus.svg';
      case SailSVGAsset.iconSquareDot:
        return 'assets/svgs/square-dot.svg';
      case SailSVGAsset.iconCornerRightDown:
        return 'assets/svgs/corner-right-down.svg';
      case SailSVGAsset.iconSquareDivide:
        return 'assets/svgs/square-divide.svg';
      case SailSVGAsset.iconBookOpen:
        return 'assets/svgs/book-open.svg';
      case SailSVGAsset.iconForklift:
        return 'assets/svgs/forklift.svg';
      case SailSVGAsset.iconCalendarCog:
        return 'assets/svgs/calendar-cog.svg';
      case SailSVGAsset.iconCastle:
        return 'assets/svgs/castle.svg';
      case SailSVGAsset.iconAreaChart:
        return 'assets/svgs/area-chart.svg';
      case SailSVGAsset.iconOrbit:
        return 'assets/svgs/orbit.svg';
      case SailSVGAsset.iconParentheses:
        return 'assets/svgs/parentheses.svg';
      case SailSVGAsset.iconProjector:
        return 'assets/svgs/projector.svg';
      case SailSVGAsset.iconPilcrowRight:
        return 'assets/svgs/pilcrow-right.svg';
      case SailSVGAsset.iconServer:
        return 'assets/svgs/server.svg';
      case SailSVGAsset.iconUserRoundCheck:
        return 'assets/svgs/user-round-check.svg';
      case SailSVGAsset.iconBolt:
        return 'assets/svgs/bolt.svg';
      case SailSVGAsset.iconTv:
        return 'assets/svgs/tv.svg';
      case SailSVGAsset.iconMessageSquareDashed:
        return 'assets/svgs/message-square-dashed.svg';
      case SailSVGAsset.iconDroplets:
        return 'assets/svgs/droplets.svg';
      case SailSVGAsset.iconSkipForward:
        return 'assets/svgs/skip-forward.svg';
      case SailSVGAsset.iconArchiveRestore:
        return 'assets/svgs/archive-restore.svg';
      case SailSVGAsset.iconVolume:
        return 'assets/svgs/volume.svg';
      case SailSVGAsset.iconLampWallUp:
        return 'assets/svgs/lamp-wall-up.svg';
      case SailSVGAsset.iconBarChart3:
        return 'assets/svgs/bar-chart-3.svg';
      case SailSVGAsset.iconDrumstick:
        return 'assets/svgs/drumstick.svg';
      case SailSVGAsset.iconUserPlus:
        return 'assets/svgs/user-plus.svg';
      case SailSVGAsset.iconBatteryMedium:
        return 'assets/svgs/battery-medium.svg';
      case SailSVGAsset.iconBookA:
        return 'assets/svgs/book-a.svg';
      case SailSVGAsset.iconBatteryCharging:
        return 'assets/svgs/battery-charging.svg';
      case SailSVGAsset.iconShapes:
        return 'assets/svgs/shapes.svg';
      case SailSVGAsset.iconFolders:
        return 'assets/svgs/folders.svg';
      case SailSVGAsset.iconSatellite:
        return 'assets/svgs/satellite.svg';
      case SailSVGAsset.iconListMinus:
        return 'assets/svgs/list-minus.svg';
      case SailSVGAsset.iconCircleArrowLeft:
        return 'assets/svgs/circle-arrow-left.svg';
      case SailSVGAsset.iconBookmarkMinus:
        return 'assets/svgs/bookmark-minus.svg';
      case SailSVGAsset.iconHeater:
        return 'assets/svgs/heater.svg';
      case SailSVGAsset.iconLayers:
        return 'assets/svgs/layers.svg';
      case SailSVGAsset.iconEarthLock:
        return 'assets/svgs/earth-lock.svg';
      case SailSVGAsset.iconSquareParkingOff:
        return 'assets/svgs/square-parking-off.svg';
      case SailSVGAsset.iconDna:
        return 'assets/svgs/dna.svg';
      case SailSVGAsset.iconMouseOff:
        return 'assets/svgs/mouse-off.svg';
      case SailSVGAsset.iconFileCheck2:
        return 'assets/svgs/file-check-2.svg';
      case SailSVGAsset.iconSlash:
        return 'assets/svgs/slash.svg';
      case SailSVGAsset.iconRadio:
        return 'assets/svgs/radio.svg';
      case SailSVGAsset.iconAlignCenterVertical:
        return 'assets/svgs/align-center-vertical.svg';
      case SailSVGAsset.iconAlarmClock:
        return 'assets/svgs/alarm-clock.svg';
      case SailSVGAsset.iconAlarmClockOff:
        return 'assets/svgs/alarm-clock-off.svg';
      case SailSVGAsset.iconBook:
        return 'assets/svgs/book.svg';
      case SailSVGAsset.iconKeyboardMusic:
        return 'assets/svgs/keyboard-music.svg';
      case SailSVGAsset.iconHotel:
        return 'assets/svgs/hotel.svg';
      case SailSVGAsset.iconBookText:
        return 'assets/svgs/book-text.svg';
      case SailSVGAsset.iconVariable:
        return 'assets/svgs/variable.svg';
      case SailSVGAsset.iconTouchpadOff:
        return 'assets/svgs/touchpad-off.svg';
      case SailSVGAsset.iconBitcoin:
        return 'assets/svgs/bitcoin.svg';
      case SailSVGAsset.iconMessageSquareX:
        return 'assets/svgs/message-square-x.svg';
      case SailSVGAsset.iconCarFront:
        return 'assets/svgs/car-front.svg';
      case SailSVGAsset.iconAlarmSmoke:
        return 'assets/svgs/alarm-smoke.svg';
      case SailSVGAsset.iconDice4:
        return 'assets/svgs/dice-4.svg';
      case SailSVGAsset.iconSkull:
        return 'assets/svgs/skull.svg';
      case SailSVGAsset.iconMailMinus:
        return 'assets/svgs/mail-minus.svg';
      case SailSVGAsset.iconBot:
        return 'assets/svgs/bot.svg';
      case SailSVGAsset.iconPlug:
        return 'assets/svgs/plug.svg';
      case SailSVGAsset.iconShieldX:
        return 'assets/svgs/shield-x.svg';
      case SailSVGAsset.iconTrainTrack:
        return 'assets/svgs/train-track.svg';
      case SailSVGAsset.iconGoal:
        return 'assets/svgs/goal.svg';
      case SailSVGAsset.iconFolderArchive:
        return 'assets/svgs/folder-archive.svg';
      case SailSVGAsset.iconSignalHigh:
        return 'assets/svgs/signal-high.svg';
      case SailSVGAsset.iconUserMinus:
        return 'assets/svgs/user-minus.svg';
      case SailSVGAsset.iconPlaneLanding:
        return 'assets/svgs/plane-landing.svg';
      case SailSVGAsset.iconCircleCheck:
        return 'assets/svgs/circle-check.svg';
      case SailSVGAsset.iconTally4:
        return 'assets/svgs/tally-4.svg';
      case SailSVGAsset.iconFileImage:
        return 'assets/svgs/file-image.svg';
      case SailSVGAsset.iconSquareDashedBottom:
        return 'assets/svgs/square-dashed-bottom.svg';
      case SailSVGAsset.iconPanelTopOpen:
        return 'assets/svgs/panel-top-open.svg';
      case SailSVGAsset.iconBell:
        return 'assets/svgs/bell.svg';
      case SailSVGAsset.iconGitBranch:
        return 'assets/svgs/git-branch.svg';
      case SailSVGAsset.iconSquareM:
        return 'assets/svgs/square-m.svg';
      case SailSVGAsset.iconCoffee:
        return 'assets/svgs/coffee.svg';
      case SailSVGAsset.iconPanelLeftDashed:
        return 'assets/svgs/panel-left-dashed.svg';
      case SailSVGAsset.iconCode:
        return 'assets/svgs/code.svg';
      case SailSVGAsset.iconRailSymbol:
        return 'assets/svgs/rail-symbol.svg';
      case SailSVGAsset.iconCircleDivide:
        return 'assets/svgs/circle-divide.svg';
      case SailSVGAsset.iconCake:
        return 'assets/svgs/cake.svg';
      case SailSVGAsset.iconSpellCheck2:
        return 'assets/svgs/spell-check-2.svg';
      case SailSVGAsset.iconSettings2:
        return 'assets/svgs/settings-2.svg';
      case SailSVGAsset.iconTally5:
        return 'assets/svgs/tally-5.svg';
      case SailSVGAsset.iconMessageCircleDashed:
        return 'assets/svgs/message-circle-dashed.svg';
      case SailSVGAsset.iconCloudMoonRain:
        return 'assets/svgs/cloud-moon-rain.svg';
      case SailSVGAsset.iconRadioTower:
        return 'assets/svgs/radio-tower.svg';
      case SailSVGAsset.iconThermometer:
        return 'assets/svgs/thermometer.svg';
      case SailSVGAsset.iconIconClose:
        return 'assets/svgs/icon_close.svg';
      case SailSVGAsset.iconMilestone:
        return 'assets/svgs/milestone.svg';
      case SailSVGAsset.iconMove3d:
        return 'assets/svgs/move-3d.svg';
      case SailSVGAsset.iconFlag:
        return 'assets/svgs/flag.svg';
      case SailSVGAsset.iconPodcast:
        return 'assets/svgs/podcast.svg';
      case SailSVGAsset.iconTvMinimalPlay:
        return 'assets/svgs/tv-minimal-play.svg';
      case SailSVGAsset.iconGitFork:
        return 'assets/svgs/git-fork.svg';
      case SailSVGAsset.iconEyeOff:
        return 'assets/svgs/eye-off.svg';
      case SailSVGAsset.iconDice5:
        return 'assets/svgs/dice-5.svg';
      case SailSVGAsset.iconTramFront:
        return 'assets/svgs/tram-front.svg';
      case SailSVGAsset.iconBattery:
        return 'assets/svgs/battery.svg';
      case SailSVGAsset.iconIconCoins:
        return 'assets/svgs/icon_coins.svg';
      case SailSVGAsset.iconBlinds:
        return 'assets/svgs/blinds.svg';
      case SailSVGAsset.iconArrowLeftToLine:
        return 'assets/svgs/arrow-left-to-line.svg';
      case SailSVGAsset.iconNewspaper:
        return 'assets/svgs/newspaper.svg';
      case SailSVGAsset.iconClipboardPenLine:
        return 'assets/svgs/clipboard-pen-line.svg';
      case SailSVGAsset.iconSnowflake:
        return 'assets/svgs/snowflake.svg';
      case SailSVGAsset.iconDisc:
        return 'assets/svgs/disc.svg';
      case SailSVGAsset.iconStepForward:
        return 'assets/svgs/step-forward.svg';
      case SailSVGAsset.iconBomb:
        return 'assets/svgs/bomb.svg';
      case SailSVGAsset.iconPiano:
        return 'assets/svgs/piano.svg';
      case SailSVGAsset.iconBookCopy:
        return 'assets/svgs/book-copy.svg';
      case SailSVGAsset.iconArrowUp01:
        return 'assets/svgs/arrow-up-0-1.svg';
      case SailSVGAsset.iconDatabaseZap:
        return 'assets/svgs/database-zap.svg';
      case SailSVGAsset.iconRotate3d:
        return 'assets/svgs/rotate-3d.svg';
      case SailSVGAsset.iconStarHalf:
        return 'assets/svgs/star-half.svg';
      case SailSVGAsset.iconSwitchCamera:
        return 'assets/svgs/switch-camera.svg';
      case SailSVGAsset.iconImagePlus:
        return 'assets/svgs/image-plus.svg';
      case SailSVGAsset.iconPencilRuler:
        return 'assets/svgs/pencil-ruler.svg';
      case SailSVGAsset.iconContainer:
        return 'assets/svgs/container.svg';
      case SailSVGAsset.iconRuler:
        return 'assets/svgs/ruler.svg';
      case SailSVGAsset.iconTurtle:
        return 'assets/svgs/turtle.svg';
      case SailSVGAsset.iconFrown:
        return 'assets/svgs/frown.svg';
      case SailSVGAsset.iconTreePine:
        return 'assets/svgs/tree-pine.svg';
      case SailSVGAsset.iconAudioLines:
        return 'assets/svgs/audio-lines.svg';
      case SailSVGAsset.iconCircleSlash:
        return 'assets/svgs/circle-slash.svg';
      case SailSVGAsset.iconNotebookText:
        return 'assets/svgs/notebook-text.svg';
      case SailSVGAsset.iconLayoutDashboard:
        return 'assets/svgs/layout-dashboard.svg';
      case SailSVGAsset.iconFileLineChart:
        return 'assets/svgs/file-line-chart.svg';
      case SailSVGAsset.iconCpu:
        return 'assets/svgs/cpu.svg';
      case SailSVGAsset.iconAlignEndHorizontal:
        return 'assets/svgs/align-end-horizontal.svg';
      case SailSVGAsset.iconFlameKindling:
        return 'assets/svgs/flame-kindling.svg';
      case SailSVGAsset.iconClipboardList:
        return 'assets/svgs/clipboard-list.svg';
      case SailSVGAsset.iconBiohazard:
        return 'assets/svgs/biohazard.svg';
      case SailSVGAsset.iconBarChart4:
        return 'assets/svgs/bar-chart-4.svg';
      case SailSVGAsset.iconFolderX:
        return 'assets/svgs/folder-x.svg';
      case SailSVGAsset.iconBookOpenCheck:
        return 'assets/svgs/book-open-check.svg';
      case SailSVGAsset.iconListOrdered:
        return 'assets/svgs/list-ordered.svg';
      case SailSVGAsset.iconFactory:
        return 'assets/svgs/factory.svg';
      case SailSVGAsset.iconBold:
        return 'assets/svgs/bold.svg';
      case SailSVGAsset.iconTablets:
        return 'assets/svgs/tablets.svg';
      case SailSVGAsset.iconIconTabWithdrawalExplorer:
        return 'assets/svgs/icon_tab_withdrawal_explorer.svg';
      case SailSVGAsset.iconFence:
        return 'assets/svgs/fence.svg';
      case SailSVGAsset.iconTrophy:
        return 'assets/svgs/trophy.svg';
      case SailSVGAsset.iconHash:
        return 'assets/svgs/hash.svg';
      case SailSVGAsset.iconShieldMinus:
        return 'assets/svgs/shield-minus.svg';
      case SailSVGAsset.iconLink2Off:
        return 'assets/svgs/link-2-off.svg';
      case SailSVGAsset.iconShare2:
        return 'assets/svgs/share-2.svg';
      case SailSVGAsset.iconBatteryFull:
        return 'assets/svgs/battery-full.svg';
      case SailSVGAsset.iconPlus:
        return 'assets/svgs/plus.svg';
      case SailSVGAsset.iconMonitorStop:
        return 'assets/svgs/monitor-stop.svg';
      case SailSVGAsset.iconPanelBottom:
        return 'assets/svgs/panel-bottom.svg';
      case SailSVGAsset.iconClipboardMinus:
        return 'assets/svgs/clipboard-minus.svg';
      case SailSVGAsset.iconAlignVerticalJustifyEnd:
        return 'assets/svgs/align-vertical-justify-end.svg';
      case SailSVGAsset.iconRabbit:
        return 'assets/svgs/rabbit.svg';
      case SailSVGAsset.iconPlugZap:
        return 'assets/svgs/plug-zap.svg';
      case SailSVGAsset.iconNut:
        return 'assets/svgs/nut.svg';
      case SailSVGAsset.iconMailPlus:
        return 'assets/svgs/mail-plus.svg';
      case SailSVGAsset.iconMoveDownRight:
        return 'assets/svgs/move-down-right.svg';
      case SailSVGAsset.iconRotateCcw:
        return 'assets/svgs/rotate-ccw.svg';
      case SailSVGAsset.iconHeartCrack:
        return 'assets/svgs/heart-crack.svg';
      case SailSVGAsset.iconFlipHorizontal2:
        return 'assets/svgs/flip-horizontal-2.svg';
      case SailSVGAsset.iconHardDrive:
        return 'assets/svgs/hard-drive.svg';
      case SailSVGAsset.iconBetweenHorizontalEnd:
        return 'assets/svgs/between-horizontal-end.svg';
      case SailSVGAsset.iconTent:
        return 'assets/svgs/tent.svg';
      case SailSVGAsset.iconHardDriveDownload:
        return 'assets/svgs/hard-drive-download.svg';
      case SailSVGAsset.iconCircleFadingPlus:
        return 'assets/svgs/circle-fading-plus.svg';
      case SailSVGAsset.iconPenLine:
        return 'assets/svgs/pen-line.svg';
      case SailSVGAsset.iconAlignVerticalSpaceAround:
        return 'assets/svgs/align-vertical-space-around.svg';
      case SailSVGAsset.iconHospital:
        return 'assets/svgs/hospital.svg';
      case SailSVGAsset.iconCaseSensitive:
        return 'assets/svgs/case-sensitive.svg';
      case SailSVGAsset.iconFocus:
        return 'assets/svgs/focus.svg';
      case SailSVGAsset.iconBluetooth:
        return 'assets/svgs/bluetooth.svg';
      case SailSVGAsset.iconAlignEndVertical:
        return 'assets/svgs/align-end-vertical.svg';
      case SailSVGAsset.iconPieChart:
        return 'assets/svgs/pie-chart.svg';
      case SailSVGAsset.iconSquareSplitVertical:
        return 'assets/svgs/square-split-vertical.svg';
      case SailSVGAsset.iconHeadphones:
        return 'assets/svgs/headphones.svg';
      case SailSVGAsset.iconTableProperties:
        return 'assets/svgs/table-properties.svg';
      case SailSVGAsset.iconGitPullRequestCreateArrow:
        return 'assets/svgs/git-pull-request-create-arrow.svg';
      case SailSVGAsset.iconFolderGit2:
        return 'assets/svgs/folder-git-2.svg';
      case SailSVGAsset.iconSquareX:
        return 'assets/svgs/square-x.svg';
      case SailSVGAsset.iconSquareAsterisk:
        return 'assets/svgs/square-asterisk.svg';
      case SailSVGAsset.iconRss:
        return 'assets/svgs/rss.svg';
      case SailSVGAsset.iconTableCellsSplit:
        return 'assets/svgs/table-cells-split.svg';
      case SailSVGAsset.iconFlower2:
        return 'assets/svgs/flower-2.svg';
      case SailSVGAsset.iconLandmark:
        return 'assets/svgs/landmark.svg';
      case SailSVGAsset.iconWifi:
        return 'assets/svgs/wifi.svg';
      case SailSVGAsset.iconCornerUpLeft:
        return 'assets/svgs/corner-up-left.svg';
      case SailSVGAsset.iconFileArchive:
        return 'assets/svgs/file-archive.svg';
      case SailSVGAsset.iconSquareArrowUpLeft:
        return 'assets/svgs/square-arrow-up-left.svg';
      case SailSVGAsset.iconArrowDownFromLine:
        return 'assets/svgs/arrow-down-from-line.svg';
      case SailSVGAsset.iconWatch:
        return 'assets/svgs/watch.svg';
      case SailSVGAsset.iconIconTransactions:
        return 'assets/svgs/icon_transactions.svg';
      case SailSVGAsset.iconSquareArrowDownRight:
        return 'assets/svgs/square-arrow-down-right.svg';
      case SailSVGAsset.iconScale:
        return 'assets/svgs/scale.svg';
      case SailSVGAsset.iconDice6:
        return 'assets/svgs/dice-6.svg';
      case SailSVGAsset.iconMessageSquareMore:
        return 'assets/svgs/message-square-more.svg';
      case SailSVGAsset.iconAmpersand:
        return 'assets/svgs/ampersand.svg';
      case SailSVGAsset.iconDnaOff:
        return 'assets/svgs/dna-off.svg';
      case SailSVGAsset.iconSquareArrowOutUpRight:
        return 'assets/svgs/square-arrow-out-up-right.svg';
      case SailSVGAsset.iconHandCoins:
        return 'assets/svgs/hand-coins.svg';
      case SailSVGAsset.iconRollerCoaster:
        return 'assets/svgs/roller-coaster.svg';
      case SailSVGAsset.iconMonitorSmartphone:
        return 'assets/svgs/monitor-smartphone.svg';
      case SailSVGAsset.iconGitCommitVertical:
        return 'assets/svgs/git-commit-vertical.svg';
      case SailSVGAsset.iconBlocks:
        return 'assets/svgs/blocks.svg';
      case SailSVGAsset.iconPopcorn:
        return 'assets/svgs/popcorn.svg';
      case SailSVGAsset.iconFileBadge:
        return 'assets/svgs/file-badge.svg';
      case SailSVGAsset.iconBadgeDollarSign:
        return 'assets/svgs/badge-dollar-sign.svg';
      case SailSVGAsset.iconUserX:
        return 'assets/svgs/user-x.svg';
      case SailSVGAsset.iconIconSuccess:
        return 'assets/svgs/icon_success.svg';
      case SailSVGAsset.iconNavigationOff:
        return 'assets/svgs/navigation-off.svg';
      case SailSVGAsset.iconKeySquare:
        return 'assets/svgs/key-square.svg';
      case SailSVGAsset.iconTicketMinus:
        return 'assets/svgs/ticket-minus.svg';
      case SailSVGAsset.iconDog:
        return 'assets/svgs/dog.svg';
      case SailSVGAsset.iconLayoutPanelLeft:
        return 'assets/svgs/layout-panel-left.svg';
      case SailSVGAsset.iconFan:
        return 'assets/svgs/fan.svg';
      case SailSVGAsset.iconRadioReceiver:
        return 'assets/svgs/radio-receiver.svg';
      case SailSVGAsset.iconLoader:
        return 'assets/svgs/loader.svg';
      case SailSVGAsset.iconPalette:
        return 'assets/svgs/palette.svg';
      case SailSVGAsset.iconPilcrowLeft:
        return 'assets/svgs/pilcrow-left.svg';
      case SailSVGAsset.iconDiamondPlus:
        return 'assets/svgs/diamond-plus.svg';
      case SailSVGAsset.iconCircleArrowOutDownLeft:
        return 'assets/svgs/circle-arrow-out-down-left.svg';
      case SailSVGAsset.iconReceiptSwissFranc:
        return 'assets/svgs/receipt-swiss-franc.svg';
      case SailSVGAsset.iconPackage2:
        return 'assets/svgs/package-2.svg';
      case SailSVGAsset.iconCaseUpper:
        return 'assets/svgs/case-upper.svg';
      case SailSVGAsset.iconRefreshCcw:
        return 'assets/svgs/refresh-ccw.svg';
      case SailSVGAsset.iconCloudFog:
        return 'assets/svgs/cloud-fog.svg';
      case SailSVGAsset.iconIconArrowDown:
        return 'assets/svgs/icon_arrow_down.svg';
      case SailSVGAsset.iconGitBranchPlus:
        return 'assets/svgs/git-branch-plus.svg';
      case SailSVGAsset.iconFileX:
        return 'assets/svgs/file-x.svg';
      case SailSVGAsset.iconHeading1:
        return 'assets/svgs/heading-1.svg';
      case SailSVGAsset.iconHop:
        return 'assets/svgs/hop.svg';
      case SailSVGAsset.iconIconPen:
        return 'assets/svgs/icon_pen.svg';
      case SailSVGAsset.iconFolderUp:
        return 'assets/svgs/folder-up.svg';
      case SailSVGAsset.iconSoup:
        return 'assets/svgs/soup.svg';
      case SailSVGAsset.iconFolderPlus:
        return 'assets/svgs/folder-plus.svg';
      case SailSVGAsset.iconBadgeRussianRuble:
        return 'assets/svgs/badge-russian-ruble.svg';
      case SailSVGAsset.iconGitMerge:
        return 'assets/svgs/git-merge.svg';
      case SailSVGAsset.iconJapaneseYen:
        return 'assets/svgs/japanese-yen.svg';
      case SailSVGAsset.iconGripHorizontal:
        return 'assets/svgs/grip-horizontal.svg';
      case SailSVGAsset.iconListX:
        return 'assets/svgs/list-x.svg';
      case SailSVGAsset.iconIconTabConsole:
        return 'assets/svgs/icon_tab_console.svg';
      case SailSVGAsset.iconShieldHalf:
        return 'assets/svgs/shield-half.svg';
      case SailSVGAsset.iconMic:
        return 'assets/svgs/mic.svg';
      case SailSVGAsset.iconVenetianMask:
        return 'assets/svgs/venetian-mask.svg';
      case SailSVGAsset.iconRainbow:
        return 'assets/svgs/rainbow.svg';
      case SailSVGAsset.iconGitPullRequestArrow:
        return 'assets/svgs/git-pull-request-arrow.svg';
      case SailSVGAsset.iconIconArrowForward:
        return 'assets/svgs/icon_arrow_forward.svg';
      case SailSVGAsset.iconSmilePlus:
        return 'assets/svgs/smile-plus.svg';
      case SailSVGAsset.iconFish:
        return 'assets/svgs/fish.svg';
      case SailSVGAsset.iconMoveUpLeft:
        return 'assets/svgs/move-up-left.svg';
      case SailSVGAsset.iconListTree:
        return 'assets/svgs/list-tree.svg';
      case SailSVGAsset.iconZoomIn:
        return 'assets/svgs/zoom-in.svg';
      case SailSVGAsset.iconCircleChevronUp:
        return 'assets/svgs/circle-chevron-up.svg';
      case SailSVGAsset.iconCircleArrowOutDownRight:
        return 'assets/svgs/circle-arrow-out-down-right.svg';
      case SailSVGAsset.iconSquareGanttChart:
        return 'assets/svgs/square-gantt-chart.svg';
      case SailSVGAsset.iconSearchCheck:
        return 'assets/svgs/search-check.svg';
      case SailSVGAsset.iconArrowDownToLine:
        return 'assets/svgs/arrow-down-to-line.svg';
      case SailSVGAsset.iconGlasses:
        return 'assets/svgs/glasses.svg';
      case SailSVGAsset.iconAlignStartVertical:
        return 'assets/svgs/align-start-vertical.svg';
      case SailSVGAsset.iconArrowsUpFromLine:
        return 'assets/svgs/arrows-up-from-line.svg';
      case SailSVGAsset.iconIconHdwallet:
        return 'assets/svgs/icon_hdwallet.svg';
      case SailSVGAsset.iconSnail:
        return 'assets/svgs/snail.svg';
      case SailSVGAsset.iconLibraryBig:
        return 'assets/svgs/library-big.svg';
      case SailSVGAsset.iconBookmarkX:
        return 'assets/svgs/bookmark-x.svg';
      case SailSVGAsset.iconBookKey:
        return 'assets/svgs/book-key.svg';
      case SailSVGAsset.iconPanelLeft:
        return 'assets/svgs/panel-left.svg';
      case SailSVGAsset.iconTestTubeDiagonal:
        return 'assets/svgs/test-tube-diagonal.svg';
      case SailSVGAsset.iconOrigami:
        return 'assets/svgs/origami.svg';
      case SailSVGAsset.iconSquareLibrary:
        return 'assets/svgs/square-library.svg';
      case SailSVGAsset.iconMessageCircleOff:
        return 'assets/svgs/message-circle-off.svg';
      case SailSVGAsset.iconSquareUserRound:
        return 'assets/svgs/square-user-round.svg';
      case SailSVGAsset.iconWandSparkles:
        return 'assets/svgs/wand-sparkles.svg';
      case SailSVGAsset.iconFileType2:
        return 'assets/svgs/file-type-2.svg';
      case SailSVGAsset.iconTextQuote:
        return 'assets/svgs/text-quote.svg';
      case SailSVGAsset.iconCaravan:
        return 'assets/svgs/caravan.svg';
      case SailSVGAsset.iconBadgeCent:
        return 'assets/svgs/badge-cent.svg';
      case SailSVGAsset.iconPanelTopDashed:
        return 'assets/svgs/panel-top-dashed.svg';
      case SailSVGAsset.iconNotebookTabs:
        return 'assets/svgs/notebook-tabs.svg';
      case SailSVGAsset.iconText:
        return 'assets/svgs/text.svg';
      case SailSVGAsset.iconTestTubes:
        return 'assets/svgs/test-tubes.svg';
      case SailSVGAsset.iconFireExtinguisher:
        return 'assets/svgs/fire-extinguisher.svg';
      case SailSVGAsset.iconEggFried:
        return 'assets/svgs/egg-fried.svg';
      case SailSVGAsset.iconFlagTriangleLeft:
        return 'assets/svgs/flag-triangle-left.svg';
      case SailSVGAsset.iconAlignRight:
        return 'assets/svgs/align-right.svg';
      case SailSVGAsset.iconTextCursor:
        return 'assets/svgs/text-cursor.svg';
      case SailSVGAsset.iconImage:
        return 'assets/svgs/image.svg';
      case SailSVGAsset.iconPanelBottomOpen:
        return 'assets/svgs/panel-bottom-open.svg';
      case SailSVGAsset.iconMaximize2:
        return 'assets/svgs/maximize-2.svg';
      case SailSVGAsset.iconIconTabSend:
        return 'assets/svgs/icon_tab_send.svg';
      case SailSVGAsset.iconLightbulb:
        return 'assets/svgs/lightbulb.svg';
      case SailSVGAsset.iconServerOff:
        return 'assets/svgs/server-off.svg';
      case SailSVGAsset.iconArrowBigLeftDash:
        return 'assets/svgs/arrow-big-left-dash.svg';
      case SailSVGAsset.iconImagePlay:
        return 'assets/svgs/image-play.svg';
      case SailSVGAsset.iconSunset:
        return 'assets/svgs/sunset.svg';
      case SailSVGAsset.iconSave:
        return 'assets/svgs/save.svg';
      case SailSVGAsset.iconSmile:
        return 'assets/svgs/smile.svg';
      case SailSVGAsset.iconSearchCode:
        return 'assets/svgs/search-code.svg';
      case SailSVGAsset.iconLamp:
        return 'assets/svgs/lamp.svg';
      case SailSVGAsset.iconSiren:
        return 'assets/svgs/siren.svg';
      case SailSVGAsset.iconImages:
        return 'assets/svgs/images.svg';
      case SailSVGAsset.iconScan:
        return 'assets/svgs/scan.svg';
      case SailSVGAsset.iconNavigation:
        return 'assets/svgs/navigation.svg';
      case SailSVGAsset.iconCloudLightning:
        return 'assets/svgs/cloud-lightning.svg';
      case SailSVGAsset.iconIconDashboardTab:
        return 'assets/svgs/icon_dashboard_tab.svg';
      case SailSVGAsset.iconCitrus:
        return 'assets/svgs/citrus.svg';
      case SailSVGAsset.iconMessageSquareDiff:
        return 'assets/svgs/message-square-diff.svg';
      case SailSVGAsset.iconBellElectric:
        return 'assets/svgs/bell-electric.svg';
      case SailSVGAsset.iconHam:
        return 'assets/svgs/ham.svg';
      case SailSVGAsset.iconCandlestickChart:
        return 'assets/svgs/candlestick-chart.svg';
      case SailSVGAsset.iconMonitorPlay:
        return 'assets/svgs/monitor-play.svg';
      case SailSVGAsset.iconBadgePoundSterling:
        return 'assets/svgs/badge-pound-sterling.svg';
      case SailSVGAsset.iconHardDriveUpload:
        return 'assets/svgs/hard-drive-upload.svg';
      case SailSVGAsset.iconAppWindow:
        return 'assets/svgs/app-window.svg';
      case SailSVGAsset.iconBadge:
        return 'assets/svgs/badge.svg';
      case SailSVGAsset.iconIconTabDepositWithdraw:
        return 'assets/svgs/icon_tab_deposit_withdraw.svg';
      case SailSVGAsset.iconTheater:
        return 'assets/svgs/theater.svg';
      case SailSVGAsset.iconIconSidechains:
        return 'assets/svgs/icon_sidechains.svg';
      case SailSVGAsset.iconPaperclip:
        return 'assets/svgs/paperclip.svg';
      case SailSVGAsset.iconHeading2:
        return 'assets/svgs/heading-2.svg';
      case SailSVGAsset.iconSquareScissors:
        return 'assets/svgs/square-scissors.svg';
      case SailSVGAsset.iconFastForward:
        return 'assets/svgs/fast-forward.svg';
      case SailSVGAsset.iconFlagTriangleRight:
        return 'assets/svgs/flag-triangle-right.svg';
      case SailSVGAsset.iconCalendarRange:
        return 'assets/svgs/calendar-range.svg';
      case SailSVGAsset.iconContactRound:
        return 'assets/svgs/contact-round.svg';
      case SailSVGAsset.iconSyringe:
        return 'assets/svgs/syringe.svg';
      case SailSVGAsset.iconSearchSlash:
        return 'assets/svgs/search-slash.svg';
      case SailSVGAsset.iconFileQuestion:
        return 'assets/svgs/file-question.svg';
      case SailSVGAsset.iconBarChartHorizontal:
        return 'assets/svgs/bar-chart-horizontal.svg';
      case SailSVGAsset.iconSticker:
        return 'assets/svgs/sticker.svg';
      case SailSVGAsset.iconAward:
        return 'assets/svgs/award.svg';
      case SailSVGAsset.iconPanelRightDashed:
        return 'assets/svgs/panel-right-dashed.svg';
      case SailSVGAsset.iconZoomOut:
        return 'assets/svgs/zoom-out.svg';
      case SailSVGAsset.iconSquareArrowOutUpLeft:
        return 'assets/svgs/square-arrow-out-up-left.svg';
      case SailSVGAsset.iconBox:
        return 'assets/svgs/box.svg';
      case SailSVGAsset.iconThumbsUp:
        return 'assets/svgs/thumbs-up.svg';
      case SailSVGAsset.iconSuperscript:
        return 'assets/svgs/superscript.svg';
      case SailSVGAsset.iconTicketPercent:
        return 'assets/svgs/ticket-percent.svg';
      case SailSVGAsset.iconBatteryLow:
        return 'assets/svgs/battery-low.svg';
      case SailSVGAsset.iconTouchpad:
        return 'assets/svgs/touchpad.svg';
      case SailSVGAsset.iconSpeech:
        return 'assets/svgs/speech.svg';
      case SailSVGAsset.iconIconConnectionStatus:
        return 'assets/svgs/icon_connection_status.svg';
      case SailSVGAsset.iconPercent:
        return 'assets/svgs/percent.svg';
      case SailSVGAsset.iconSquareChevronDown:
        return 'assets/svgs/square-chevron-down.svg';
      case SailSVGAsset.iconSquare:
        return 'assets/svgs/square.svg';
      case SailSVGAsset.iconCrown:
        return 'assets/svgs/crown.svg';
      case SailSVGAsset.iconBluetoothSearching:
        return 'assets/svgs/bluetooth-searching.svg';
      case SailSVGAsset.iconTimerReset:
        return 'assets/svgs/timer-reset.svg';
      case SailSVGAsset.iconStethoscope:
        return 'assets/svgs/stethoscope.svg';
      case SailSVGAsset.iconIconSidechain:
        return 'assets/svgs/icon_sidechain.svg';
      case SailSVGAsset.iconEclipse:
        return 'assets/svgs/eclipse.svg';
      case SailSVGAsset.iconDonut:
        return 'assets/svgs/donut.svg';
      case SailSVGAsset.iconCandyCane:
        return 'assets/svgs/candy-cane.svg';
      case SailSVGAsset.iconPlay:
        return 'assets/svgs/play.svg';
      case SailSVGAsset.iconFolderHeart:
        return 'assets/svgs/folder-heart.svg';
      case SailSVGAsset.iconPenOff:
        return 'assets/svgs/pen-off.svg';
      case SailSVGAsset.iconFileCheck:
        return 'assets/svgs/file-check.svg';
      case SailSVGAsset.iconLeafyGreen:
        return 'assets/svgs/leafy-green.svg';
      case SailSVGAsset.iconTangent:
        return 'assets/svgs/tangent.svg';
      case SailSVGAsset.iconBookAudio:
        return 'assets/svgs/book-audio.svg';
      case SailSVGAsset.iconTable:
        return 'assets/svgs/table.svg';
      case SailSVGAsset.iconSplit:
        return 'assets/svgs/split.svg';
      case SailSVGAsset.iconBarcode:
        return 'assets/svgs/barcode.svg';
      case SailSVGAsset.iconVideotape:
        return 'assets/svgs/videotape.svg';
      case SailSVGAsset.iconIconDelete:
        return 'assets/svgs/icon_delete.svg';
      case SailSVGAsset.iconScroll:
        return 'assets/svgs/scroll.svg';
      case SailSVGAsset.iconPhoneCall:
        return 'assets/svgs/phone-call.svg';
      case SailSVGAsset.iconColumns4:
        return 'assets/svgs/columns-4.svg';
      case SailSVGAsset.iconBaggageClaim:
        return 'assets/svgs/baggage-claim.svg';
      case SailSVGAsset.iconCircleArrowOutUpRight:
        return 'assets/svgs/circle-arrow-out-up-right.svg';
      case SailSVGAsset.iconRadiation:
        return 'assets/svgs/radiation.svg';
      case SailSVGAsset.iconSpeaker:
        return 'assets/svgs/speaker.svg';
      case SailSVGAsset.iconUserRoundSearch:
        return 'assets/svgs/user-round-search.svg';
      case SailSVGAsset.iconUndoDot:
        return 'assets/svgs/undo-dot.svg';
      case SailSVGAsset.iconFacebook:
        return 'assets/svgs/facebook.svg';
      case SailSVGAsset.iconCodesandbox:
        return 'assets/svgs/codesandbox.svg';
      case SailSVGAsset.iconFileDown:
        return 'assets/svgs/file-down.svg';
      case SailSVGAsset.iconBadgeCheck:
        return 'assets/svgs/badge-check.svg';
      case SailSVGAsset.iconBaby:
        return 'assets/svgs/baby.svg';
      case SailSVGAsset.iconSmartphoneCharging:
        return 'assets/svgs/smartphone-charging.svg';
      case SailSVGAsset.iconBookPlus:
        return 'assets/svgs/book-plus.svg';
      case SailSVGAsset.iconUnplug:
        return 'assets/svgs/unplug.svg';
      case SailSVGAsset.iconHeading3:
        return 'assets/svgs/heading-3.svg';
      case SailSVGAsset.iconBluetoothConnected:
        return 'assets/svgs/bluetooth-connected.svg';
      case SailSVGAsset.iconIconCheck:
        return 'assets/svgs/icon_check.svg';
      case SailSVGAsset.iconCamera:
        return 'assets/svgs/camera.svg';
      case SailSVGAsset.iconLink2:
        return 'assets/svgs/link-2.svg';
      case SailSVGAsset.iconPrinter:
        return 'assets/svgs/printer.svg';
      case SailSVGAsset.iconListCollapse:
        return 'assets/svgs/list-collapse.svg';
      case SailSVGAsset.iconWorkflow:
        return 'assets/svgs/workflow.svg';
      case SailSVGAsset.iconTrees:
        return 'assets/svgs/trees.svg';
      case SailSVGAsset.iconPanelLeftClose:
        return 'assets/svgs/panel-left-close.svg';
      case SailSVGAsset.iconGitGraph:
        return 'assets/svgs/git-graph.svg';
      case SailSVGAsset.iconRedo:
        return 'assets/svgs/redo.svg';
      case SailSVGAsset.iconCaptionsOff:
        return 'assets/svgs/captions-off.svg';
      case SailSVGAsset.iconClub:
        return 'assets/svgs/club.svg';
      case SailSVGAsset.iconFolderMinus:
        return 'assets/svgs/folder-minus.svg';
      case SailSVGAsset.iconMoveDiagonal2:
        return 'assets/svgs/move-diagonal-2.svg';
      case SailSVGAsset.iconCombine:
        return 'assets/svgs/combine.svg';
      case SailSVGAsset.iconArrowUpRight:
        return 'assets/svgs/arrow-up-right.svg';
      case SailSVGAsset.iconTruck:
        return 'assets/svgs/truck.svg';
      case SailSVGAsset.iconLayoutPanelTop:
        return 'assets/svgs/layout-panel-top.svg';
      case SailSVGAsset.iconLifeBuoy:
        return 'assets/svgs/life-buoy.svg';
      case SailSVGAsset.iconUserSearch:
        return 'assets/svgs/user-search.svg';
      case SailSVGAsset.iconSquareUser:
        return 'assets/svgs/square-user.svg';
      case SailSVGAsset.iconTableColumnsSplit:
        return 'assets/svgs/table-columns-split.svg';
      case SailSVGAsset.iconBetweenHorizontalStart:
        return 'assets/svgs/between-horizontal-start.svg';
      case SailSVGAsset.iconPickaxe:
        return 'assets/svgs/pickaxe.svg';
      case SailSVGAsset.iconPackageX:
        return 'assets/svgs/package-x.svg';
      case SailSVGAsset.iconPenTool:
        return 'assets/svgs/pen-tool.svg';
      case SailSVGAsset.iconAlarmClockMinus:
        return 'assets/svgs/alarm-clock-minus.svg';
      case SailSVGAsset.iconPanelsLeftBottom:
        return 'assets/svgs/panels-left-bottom.svg';
      case SailSVGAsset.iconCircleGauge:
        return 'assets/svgs/circle-gauge.svg';
      case SailSVGAsset.iconFolderCog:
        return 'assets/svgs/folder-cog.svg';
      case SailSVGAsset.iconAtSign:
        return 'assets/svgs/at-sign.svg';
      case SailSVGAsset.iconRotateCcwSquare:
        return 'assets/svgs/rotate-ccw-square.svg';
      case SailSVGAsset.iconCircleArrowRight:
        return 'assets/svgs/circle-arrow-right.svg';
      case SailSVGAsset.iconShieldAlert:
        return 'assets/svgs/shield-alert.svg';
      case SailSVGAsset.iconMapPinOff:
        return 'assets/svgs/map-pin-off.svg';
      case SailSVGAsset.iconListRestart:
        return 'assets/svgs/list-restart.svg';
      case SailSVGAsset.iconHandMetal:
        return 'assets/svgs/hand-metal.svg';
      case SailSVGAsset.iconEgg:
        return 'assets/svgs/egg.svg';
      case SailSVGAsset.iconCarTaxiFront:
        return 'assets/svgs/car-taxi-front.svg';
      case SailSVGAsset.iconSquareMousePointer:
        return 'assets/svgs/square-mouse-pointer.svg';
      case SailSVGAsset.iconMonitorX:
        return 'assets/svgs/monitor-x.svg';
      case SailSVGAsset.iconSquareTerminal:
        return 'assets/svgs/square-terminal.svg';
      case SailSVGAsset.iconGrid2x2Check:
        return 'assets/svgs/grid-2x2-check.svg';
      case SailSVGAsset.iconBus:
        return 'assets/svgs/bus.svg';
      case SailSVGAsset.iconFilePenLine:
        return 'assets/svgs/file-pen-line.svg';
      case SailSVGAsset.iconIconCast:
        return 'assets/svgs/icon_cast.svg';
      case SailSVGAsset.iconBookHeart:
        return 'assets/svgs/book-heart.svg';
      case SailSVGAsset.iconInfinity:
        return 'assets/svgs/infinity.svg';
      case SailSVGAsset.iconGem:
        return 'assets/svgs/gem.svg';
      case SailSVGAsset.iconFilterX:
        return 'assets/svgs/filter-x.svg';
      case SailSVGAsset.iconGitCompare:
        return 'assets/svgs/git-compare.svg';
      case SailSVGAsset.iconReceiptCent:
        return 'assets/svgs/receipt-cent.svg';
      case SailSVGAsset.iconFeather:
        return 'assets/svgs/feather.svg';
      case SailSVGAsset.iconWebhookOff:
        return 'assets/svgs/webhook-off.svg';
      case SailSVGAsset.iconTrash:
        return 'assets/svgs/trash.svg';
      case SailSVGAsset.iconTreePalm:
        return 'assets/svgs/tree-palm.svg';
      case SailSVGAsset.iconArrowDown10:
        return 'assets/svgs/arrow-down-1-0.svg';
      case SailSVGAsset.iconDatabaseBackup:
        return 'assets/svgs/database-backup.svg';
      case SailSVGAsset.iconArmchair:
        return 'assets/svgs/armchair.svg';
      case SailSVGAsset.iconWifiOff:
        return 'assets/svgs/wifi-off.svg';
      case SailSVGAsset.iconUserRound:
        return 'assets/svgs/user-round.svg';
      case SailSVGAsset.iconUngroup:
        return 'assets/svgs/ungroup.svg';
      case SailSVGAsset.iconBookLock:
        return 'assets/svgs/book-lock.svg';
      case SailSVGAsset.iconLeaf:
        return 'assets/svgs/leaf.svg';
      case SailSVGAsset.iconArrowDownWideNarrow:
        return 'assets/svgs/arrow-down-wide-narrow.svg';
      case SailSVGAsset.iconFileLock2:
        return 'assets/svgs/file-lock-2.svg';
      case SailSVGAsset.iconAppWindowMac:
        return 'assets/svgs/app-window-mac.svg';
      case SailSVGAsset.iconArrowUpZA:
        return 'assets/svgs/arrow-up-z-a.svg';
      case SailSVGAsset.iconScanBarcode:
        return 'assets/svgs/scan-barcode.svg';
      case SailSVGAsset.iconCornerLeftDown:
        return 'assets/svgs/corner-left-down.svg';
      case SailSVGAsset.iconMessageSquarePlus:
        return 'assets/svgs/message-square-plus.svg';
      case SailSVGAsset.iconFolderClock:
        return 'assets/svgs/folder-clock.svg';
      case SailSVGAsset.iconPaintbrushVertical:
        return 'assets/svgs/paintbrush-vertical.svg';
      case SailSVGAsset.iconDollarSign:
        return 'assets/svgs/dollar-sign.svg';
      case SailSVGAsset.iconTriangleRight:
        return 'assets/svgs/triangle-right.svg';
      case SailSVGAsset.iconIndianRupee:
        return 'assets/svgs/indian-rupee.svg';
      case SailSVGAsset.iconConstruction:
        return 'assets/svgs/construction.svg';
      case SailSVGAsset.iconCirclePlus:
        return 'assets/svgs/circle-plus.svg';
      case SailSVGAsset.iconGraduationCap:
        return 'assets/svgs/graduation-cap.svg';
      case SailSVGAsset.iconScanFace:
        return 'assets/svgs/scan-face.svg';
      case SailSVGAsset.iconFishSymbol:
        return 'assets/svgs/fish-symbol.svg';
      case SailSVGAsset.iconMonitorSpeaker:
        return 'assets/svgs/monitor-speaker.svg';
      case SailSVGAsset.iconGuitar:
        return 'assets/svgs/guitar.svg';
      case SailSVGAsset.iconStar:
        return 'assets/svgs/star.svg';
      case SailSVGAsset.iconLockKeyholeOpen:
        return 'assets/svgs/lock-keyhole-open.svg';
      case SailSVGAsset.iconMonitorCheck:
        return 'assets/svgs/monitor-check.svg';
      case SailSVGAsset.iconSandwich:
        return 'assets/svgs/sandwich.svg';
      case SailSVGAsset.iconChefHat:
        return 'assets/svgs/chef-hat.svg';
      case SailSVGAsset.iconHeading6:
        return 'assets/svgs/heading-6.svg';
      case SailSVGAsset.iconCloudOff:
        return 'assets/svgs/cloud-off.svg';
      case SailSVGAsset.iconSaveAll:
        return 'assets/svgs/save-all.svg';
      case SailSVGAsset.iconSun:
        return 'assets/svgs/sun.svg';
      case SailSVGAsset.iconWrench:
        return 'assets/svgs/wrench.svg';
      case SailSVGAsset.iconSignalMedium:
        return 'assets/svgs/signal-medium.svg';
      case SailSVGAsset.iconGrab:
        return 'assets/svgs/grab.svg';
      case SailSVGAsset.iconPyramid:
        return 'assets/svgs/pyramid.svg';
      case SailSVGAsset.iconBookMinus:
        return 'assets/svgs/book-minus.svg';
      case SailSVGAsset.iconGauge:
        return 'assets/svgs/gauge.svg';
      case SailSVGAsset.iconIconInfo:
        return 'assets/svgs/icon_info.svg';
      case SailSVGAsset.iconMessageSquare:
        return 'assets/svgs/message-square.svg';
      case SailSVGAsset.iconBugPlay:
        return 'assets/svgs/bug-play.svg';
      case SailSVGAsset.iconBookX:
        return 'assets/svgs/book-x.svg';
      case SailSVGAsset.iconHeading4:
        return 'assets/svgs/heading-4.svg';
      case SailSVGAsset.iconPizza:
        return 'assets/svgs/pizza.svg';
      case SailSVGAsset.iconUnlink:
        return 'assets/svgs/unlink.svg';
      case SailSVGAsset.iconChevronsDownUp:
        return 'assets/svgs/chevrons-down-up.svg';
      case SailSVGAsset.iconBone:
        return 'assets/svgs/bone.svg';
      case SailSVGAsset.iconFlashlightOff:
        return 'assets/svgs/flashlight-off.svg';
      case SailSVGAsset.iconFileJson2:
        return 'assets/svgs/file-json-2.svg';
      case SailSVGAsset.iconAnchor:
        return 'assets/svgs/anchor.svg';
      case SailSVGAsset.iconHammer:
        return 'assets/svgs/hammer.svg';
      case SailSVGAsset.iconPlug2:
        return 'assets/svgs/plug-2.svg';
      case SailSVGAsset.iconNotebookPen:
        return 'assets/svgs/notebook-pen.svg';
      case SailSVGAsset.iconChevronsUp:
        return 'assets/svgs/chevrons-up.svg';
      case SailSVGAsset.iconColumns3:
        return 'assets/svgs/columns-3.svg';
      case SailSVGAsset.iconMoveHorizontal:
        return 'assets/svgs/move-horizontal.svg';
      case SailSVGAsset.iconHighlighter:
        return 'assets/svgs/highlighter.svg';
      case SailSVGAsset.iconSquareArrowUpRight:
        return 'assets/svgs/square-arrow-up-right.svg';
      case SailSVGAsset.iconTabletSmartphone:
        return 'assets/svgs/tablet-smartphone.svg';
      case SailSVGAsset.iconCircleStop:
        return 'assets/svgs/circle-stop.svg';
      case SailSVGAsset.iconTwitch:
        return 'assets/svgs/twitch.svg';
      case SailSVGAsset.iconBanana:
        return 'assets/svgs/banana.svg';
      case SailSVGAsset.iconTreeDeciduous:
        return 'assets/svgs/tree-deciduous.svg';
      case SailSVGAsset.iconFolderLock:
        return 'assets/svgs/folder-lock.svg';
      case SailSVGAsset.iconIconRestart:
        return 'assets/svgs/icon_restart.svg';
      case SailSVGAsset.iconLocate:
        return 'assets/svgs/locate.svg';
      case SailSVGAsset.iconListMusic:
        return 'assets/svgs/list-music.svg';
      case SailSVGAsset.iconBug:
        return 'assets/svgs/bug.svg';
      case SailSVGAsset.iconPanelTop:
        return 'assets/svgs/panel-top.svg';
      case SailSVGAsset.iconMessageSquareCode:
        return 'assets/svgs/message-square-code.svg';
      case SailSVGAsset.iconMailOpen:
        return 'assets/svgs/mail-open.svg';
      case SailSVGAsset.iconYoutube:
        return 'assets/svgs/youtube.svg';
      case SailSVGAsset.iconChevronsLeftRight:
        return 'assets/svgs/chevrons-left-right.svg';
      case SailSVGAsset.iconBookmarkPlus:
        return 'assets/svgs/bookmark-plus.svg';
      case SailSVGAsset.iconAArrowUp:
        return 'assets/svgs/a-arrow-up.svg';
      case SailSVGAsset.iconTowerControl:
        return 'assets/svgs/tower-control.svg';
      case SailSVGAsset.iconBookUp:
        return 'assets/svgs/book-up.svg';
      case SailSVGAsset.iconPocketKnife:
        return 'assets/svgs/pocket-knife.svg';
      case SailSVGAsset.iconShovel:
        return 'assets/svgs/shovel.svg';
      case SailSVGAsset.iconCompass:
        return 'assets/svgs/compass.svg';
      case SailSVGAsset.iconFileMinus2:
        return 'assets/svgs/file-minus-2.svg';
      case SailSVGAsset.iconAlignHorizontalJustifyEnd:
        return 'assets/svgs/align-horizontal-justify-end.svg';
      case SailSVGAsset.iconServerCrash:
        return 'assets/svgs/server-crash.svg';
      case SailSVGAsset.iconTrafficCone:
        return 'assets/svgs/traffic-cone.svg';
      case SailSVGAsset.iconPlaneTakeoff:
        return 'assets/svgs/plane-takeoff.svg';
      case SailSVGAsset.iconIconTabStarters:
        return 'assets/svgs/icon_tab_starters.svg';
      case SailSVGAsset.iconFolderKanban:
        return 'assets/svgs/folder-kanban.svg';
      case SailSVGAsset.iconMailSearch:
        return 'assets/svgs/mail-search.svg';
      case SailSVGAsset.iconImageUp:
        return 'assets/svgs/image-up.svg';
      case SailSVGAsset.iconCloudMoon:
        return 'assets/svgs/cloud-moon.svg';
      case SailSVGAsset.iconColumns2:
        return 'assets/svgs/columns-2.svg';
      case SailSVGAsset.iconWarehouse:
        return 'assets/svgs/warehouse.svg';
      case SailSVGAsset.iconRotateCwSquare:
        return 'assets/svgs/rotate-cw-square.svg';
      case SailSVGAsset.iconSquareFunction:
        return 'assets/svgs/square-function.svg';
      case SailSVGAsset.iconFrame:
        return 'assets/svgs/frame.svg';
      case SailSVGAsset.iconCreditCard:
        return 'assets/svgs/credit-card.svg';
      case SailSVGAsset.iconCircleArrowDown:
        return 'assets/svgs/circle-arrow-down.svg';
      case SailSVGAsset.iconTable2:
        return 'assets/svgs/table-2.svg';
      case SailSVGAsset.iconFileKey2:
        return 'assets/svgs/file-key-2.svg';
      case SailSVGAsset.iconCopyleft:
        return 'assets/svgs/copyleft.svg';
      case SailSVGAsset.iconGrid3x3:
        return 'assets/svgs/grid-3x3.svg';
      case SailSVGAsset.iconTicketX:
        return 'assets/svgs/ticket-x.svg';
      case SailSVGAsset.iconAlignVerticalJustifyStart:
        return 'assets/svgs/align-vertical-justify-start.svg';
      case SailSVGAsset.iconHeartOff:
        return 'assets/svgs/heart-off.svg';
      case SailSVGAsset.iconCylinder:
        return 'assets/svgs/cylinder.svg';
      case SailSVGAsset.iconComputer:
        return 'assets/svgs/computer.svg';
      case SailSVGAsset.iconBookType:
        return 'assets/svgs/book-type.svg';
      case SailSVGAsset.iconPillBottle:
        return 'assets/svgs/pill-bottle.svg';
      case SailSVGAsset.iconHeading5:
        return 'assets/svgs/heading-5.svg';
      case SailSVGAsset.iconThermometerSun:
        return 'assets/svgs/thermometer-sun.svg';
      case SailSVGAsset.iconBadgeHelp:
        return 'assets/svgs/badge-help.svg';
      case SailSVGAsset.iconLocateOff:
        return 'assets/svgs/locate-off.svg';
      case SailSVGAsset.iconReplyAll:
        return 'assets/svgs/reply-all.svg';
      case SailSVGAsset.iconPencil:
        return 'assets/svgs/pencil.svg';
      case SailSVGAsset.iconCloudRain:
        return 'assets/svgs/cloud-rain.svg';
      case SailSVGAsset.iconSendToBack:
        return 'assets/svgs/send-to-back.svg';
      case SailSVGAsset.iconIconTabOperationStatuses:
        return 'assets/svgs/icon_tab_operation_statuses.svg';
      case SailSVGAsset.iconGitPullRequestClosed:
        return 'assets/svgs/git-pull-request-closed.svg';
      case SailSVGAsset.iconArrowBigRightDash:
        return 'assets/svgs/arrow-big-right-dash.svg';
      case SailSVGAsset.iconAlignVerticalDistributeStart:
        return 'assets/svgs/align-vertical-distribute-start.svg';
      case SailSVGAsset.iconBookDown:
        return 'assets/svgs/book-down.svg';
      case SailSVGAsset.iconIconCalendar:
        return 'assets/svgs/icon_calendar.svg';
      case SailSVGAsset.iconPoundSterling:
        return 'assets/svgs/pound-sterling.svg';
      case SailSVGAsset.iconMonitorUp:
        return 'assets/svgs/monitor-up.svg';
      case SailSVGAsset.iconBeanOff:
        return 'assets/svgs/bean-off.svg';
      case SailSVGAsset.iconTrash2:
        return 'assets/svgs/trash-2.svg';
      case SailSVGAsset.iconCircleUser:
        return 'assets/svgs/circle-user.svg';
      case SailSVGAsset.iconSkipBack:
        return 'assets/svgs/skip-back.svg';
      case SailSVGAsset.iconFilePlus:
        return 'assets/svgs/file-plus.svg';
      case SailSVGAsset.iconScrollText:
        return 'assets/svgs/scroll-text.svg';
      case SailSVGAsset.iconGanttChart:
        return 'assets/svgs/gantt-chart.svg';
      case SailSVGAsset.iconDiamond:
        return 'assets/svgs/diamond.svg';
      case SailSVGAsset.iconCommand:
        return 'assets/svgs/command.svg';
      case SailSVGAsset.iconPackageCheck:
        return 'assets/svgs/package-check.svg';
      case SailSVGAsset.iconAlignCenterHorizontal:
        return 'assets/svgs/align-center-horizontal.svg';
      case SailSVGAsset.iconClock:
        return 'assets/svgs/clock.svg';
      case SailSVGAsset.iconBellRing:
        return 'assets/svgs/bell-ring.svg';
      case SailSVGAsset.iconRemoveFormatting:
        return 'assets/svgs/remove-formatting.svg';
      case SailSVGAsset.iconRouter:
        return 'assets/svgs/router.svg';
      case SailSVGAsset.iconFootprints:
        return 'assets/svgs/footprints.svg';
      case SailSVGAsset.iconOctagon:
        return 'assets/svgs/octagon.svg';
      case SailSVGAsset.iconArrowBigLeft:
        return 'assets/svgs/arrow-big-left.svg';
      case SailSVGAsset.iconTableRowsSplit:
        return 'assets/svgs/table-rows-split.svg';
      case SailSVGAsset.iconPhone:
        return 'assets/svgs/phone.svg';
      case SailSVGAsset.iconCircleX:
        return 'assets/svgs/circle-x.svg';
      case SailSVGAsset.iconLandPlot:
        return 'assets/svgs/land-plot.svg';
      case SailSVGAsset.iconAlignHorizontalJustifyCenter:
        return 'assets/svgs/align-horizontal-justify-center.svg';
      case SailSVGAsset.iconSunSnow:
        return 'assets/svgs/sun-snow.svg';
      case SailSVGAsset.iconIconDeposit:
        return 'assets/svgs/icon_deposit.svg';
      case SailSVGAsset.iconImageOff:
        return 'assets/svgs/image-off.svg';
      case SailSVGAsset.iconUmbrellaOff:
        return 'assets/svgs/umbrella-off.svg';
      case SailSVGAsset.iconArrowDownAZ:
        return 'assets/svgs/arrow-down-a-z.svg';
      case SailSVGAsset.iconPanelLeftOpen:
        return 'assets/svgs/panel-left-open.svg';
      case SailSVGAsset.iconBrainCircuit:
        return 'assets/svgs/brain-circuit.svg';
      case SailSVGAsset.iconMoveVertical:
        return 'assets/svgs/move-vertical.svg';
      case SailSVGAsset.iconUsersRound:
        return 'assets/svgs/users-round.svg';
      case SailSVGAsset.iconSalad:
        return 'assets/svgs/salad.svg';
      case SailSVGAsset.iconDumbbell:
        return 'assets/svgs/dumbbell.svg';
      case SailSVGAsset.iconTractor:
        return 'assets/svgs/tractor.svg';
      case SailSVGAsset.iconWaves:
        return 'assets/svgs/waves.svg';
      case SailSVGAsset.iconFolderClosed:
        return 'assets/svgs/folder-closed.svg';
      case SailSVGAsset.iconEye:
        return 'assets/svgs/eye.svg';
      case SailSVGAsset.iconUserRoundCog:
        return 'assets/svgs/user-round-cog.svg';
      case SailSVGAsset.iconIndentIncrease:
        return 'assets/svgs/indent-increase.svg';
      case SailSVGAsset.iconMousePointerBan:
        return 'assets/svgs/mouse-pointer-ban.svg';
      case SailSVGAsset.iconBadgeAlert:
        return 'assets/svgs/badge-alert.svg';
      case SailSVGAsset.iconServerCog:
        return 'assets/svgs/server-cog.svg';
      case SailSVGAsset.iconPipette:
        return 'assets/svgs/pipette.svg';
      case SailSVGAsset.iconPhoneOff:
        return 'assets/svgs/phone-off.svg';
      case SailSVGAsset.iconFlower:
        return 'assets/svgs/flower.svg';
      case SailSVGAsset.iconBanknote:
        return 'assets/svgs/banknote.svg';
      case SailSVGAsset.iconSprout:
        return 'assets/svgs/sprout.svg';
      case SailSVGAsset.iconBrickWall:
        return 'assets/svgs/brick-wall.svg';
      case SailSVGAsset.iconCopyCheck:
        return 'assets/svgs/copy-check.svg';
      case SailSVGAsset.iconRectangleVertical:
        return 'assets/svgs/rectangle-vertical.svg';
      case SailSVGAsset.iconPill:
        return 'assets/svgs/pill.svg';
      case SailSVGAsset.iconCodepen:
        return 'assets/svgs/codepen.svg';
      case SailSVGAsset.iconDribbble:
        return 'assets/svgs/dribbble.svg';
      case SailSVGAsset.iconMessageCirclePlus:
        return 'assets/svgs/message-circle-plus.svg';
      case SailSVGAsset.iconAxe:
        return 'assets/svgs/axe.svg';
      case SailSVGAsset.iconSquarePlus:
        return 'assets/svgs/square-plus.svg';
      case SailSVGAsset.iconGift:
        return 'assets/svgs/gift.svg';
      case SailSVGAsset.iconReceiptRussianRuble:
        return 'assets/svgs/receipt-russian-ruble.svg';
      case SailSVGAsset.iconPackagePlus:
        return 'assets/svgs/package-plus.svg';
      case SailSVGAsset.iconIconReceive:
        return 'assets/svgs/icon_receive.svg';
      case SailSVGAsset.iconExternalLink:
        return 'assets/svgs/external-link.svg';
      case SailSVGAsset.iconLineChart:
        return 'assets/svgs/line-chart.svg';
      case SailSVGAsset.iconCurrency:
        return 'assets/svgs/currency.svg';
      case SailSVGAsset.iconWand:
        return 'assets/svgs/wand.svg';
      case SailSVGAsset.iconFileMusic:
        return 'assets/svgs/file-music.svg';
      case SailSVGAsset.iconCar:
        return 'assets/svgs/car.svg';
      case SailSVGAsset.iconZap:
        return 'assets/svgs/zap.svg';
      case SailSVGAsset.iconTrello:
        return 'assets/svgs/trello.svg';
      case SailSVGAsset.iconListChecks:
        return 'assets/svgs/list-checks.svg';
      case SailSVGAsset.iconMessageSquareReply:
        return 'assets/svgs/message-square-reply.svg';
      case SailSVGAsset.iconBadgeX:
        return 'assets/svgs/badge-x.svg';
      case SailSVGAsset.iconIconWarning:
        return 'assets/svgs/icon_warning.svg';
      case SailSVGAsset.iconBuilding2:
        return 'assets/svgs/building-2.svg';
      case SailSVGAsset.iconMoonStar:
        return 'assets/svgs/moon-star.svg';
      case SailSVGAsset.iconClock1:
        return 'assets/svgs/clock-1.svg';
      case SailSVGAsset.iconCigaretteOff:
        return 'assets/svgs/cigarette-off.svg';
      case SailSVGAsset.iconBinary:
        return 'assets/svgs/binary.svg';
      case SailSVGAsset.iconChevronLast:
        return 'assets/svgs/chevron-last.svg';
      case SailSVGAsset.iconPointerOff:
        return 'assets/svgs/pointer-off.svg';
      case SailSVGAsset.iconMousePointer2:
        return 'assets/svgs/mouse-pointer-2.svg';
      case SailSVGAsset.iconPackageSearch:
        return 'assets/svgs/package-search.svg';
      case SailSVGAsset.iconMicOff:
        return 'assets/svgs/mic-off.svg';
      case SailSVGAsset.iconLampDesk:
        return 'assets/svgs/lamp-desk.svg';
      case SailSVGAsset.iconShare:
        return 'assets/svgs/share.svg';
      case SailSVGAsset.iconCircleParkingOff:
        return 'assets/svgs/circle-parking-off.svg';
      case SailSVGAsset.iconTags:
        return 'assets/svgs/tags.svg';
      case SailSVGAsset.iconSquareBottomDashedScissors:
        return 'assets/svgs/square-bottom-dashed-scissors.svg';
      case SailSVGAsset.iconIconTabBmm:
        return 'assets/svgs/icon_tab_bmm.svg';
      case SailSVGAsset.iconAlbum:
        return 'assets/svgs/album.svg';
      case SailSVGAsset.iconKeyRound:
        return 'assets/svgs/key-round.svg';
      case SailSVGAsset.iconSquareCode:
        return 'assets/svgs/square-code.svg';
      case SailSVGAsset.iconIconLightDarkMode:
        return 'assets/svgs/icon_light_dark_mode.svg';
      case SailSVGAsset.iconFolderSearch2:
        return 'assets/svgs/folder-search-2.svg';
      case SailSVGAsset.iconArrowUp:
        return 'assets/svgs/arrow-up.svg';
      case SailSVGAsset.iconCircleArrowOutUpLeft:
        return 'assets/svgs/circle-arrow-out-up-left.svg';
      case SailSVGAsset.iconMicroscope:
        return 'assets/svgs/microscope.svg';
      case SailSVGAsset.iconTestTube:
        return 'assets/svgs/test-tube.svg';
      case SailSVGAsset.iconBellOff:
        return 'assets/svgs/bell-off.svg';
      case SailSVGAsset.iconLinkedin:
        return 'assets/svgs/linkedin.svg';
      case SailSVGAsset.iconArrowDownNarrowWide:
        return 'assets/svgs/arrow-down-narrow-wide.svg';
      case SailSVGAsset.iconClock3:
        return 'assets/svgs/clock-3.svg';
      case SailSVGAsset.iconPanelRight:
        return 'assets/svgs/panel-right.svg';
      case SailSVGAsset.iconDrum:
        return 'assets/svgs/drum.svg';
      case SailSVGAsset.iconView:
        return 'assets/svgs/view.svg';
      case SailSVGAsset.iconMusic2:
        return 'assets/svgs/music-2.svg';
      case SailSVGAsset.iconWrapText:
        return 'assets/svgs/wrap-text.svg';
      case SailSVGAsset.iconGitCompareArrows:
        return 'assets/svgs/git-compare-arrows.svg';
      case SailSVGAsset.iconCalendarMinus:
        return 'assets/svgs/calendar-minus.svg';
      case SailSVGAsset.iconBookImage:
        return 'assets/svgs/book-image.svg';
      case SailSVGAsset.iconFileVolume2:
        return 'assets/svgs/file-volume-2.svg';
      case SailSVGAsset.iconUserRoundX:
        return 'assets/svgs/user-round-x.svg';
      case SailSVGAsset.iconUndo:
        return 'assets/svgs/undo.svg';
      case SailSVGAsset.iconVideo:
        return 'assets/svgs/video.svg';
      case SailSVGAsset.iconIconHome:
        return 'assets/svgs/icon_home.svg';
      case SailSVGAsset.iconCircleEllipsis:
        return 'assets/svgs/circle-ellipsis.svg';
      case SailSVGAsset.iconActivity:
        return 'assets/svgs/activity.svg';
      case SailSVGAsset.iconPencilLine:
        return 'assets/svgs/pencil-line.svg';
      case SailSVGAsset.iconIconFormat:
        return 'assets/svgs/icon_format.svg';
      case SailSVGAsset.iconPersonStanding:
        return 'assets/svgs/person-standing.svg';
      case SailSVGAsset.iconTwitter:
        return 'assets/svgs/twitter.svg';
      case SailSVGAsset.iconMapPin:
        return 'assets/svgs/map-pin.svg';
      case SailSVGAsset.iconFolderInput:
        return 'assets/svgs/folder-input.svg';
      case SailSVGAsset.iconFilter:
        return 'assets/svgs/filter.svg';
      case SailSVGAsset.iconLightbulbOff:
        return 'assets/svgs/lightbulb-off.svg';
      case SailSVGAsset.iconPhoneIncoming:
        return 'assets/svgs/phone-incoming.svg';
      case SailSVGAsset.iconRefrigerator:
        return 'assets/svgs/refrigerator.svg';
      case SailSVGAsset.iconItalic:
        return 'assets/svgs/italic.svg';
      case SailSVGAsset.iconListEnd:
        return 'assets/svgs/list-end.svg';
      case SailSVGAsset.iconHandshake:
        return 'assets/svgs/handshake.svg';
      case SailSVGAsset.iconChevronsLeft:
        return 'assets/svgs/chevrons-left.svg';
      case SailSVGAsset.iconRows2:
        return 'assets/svgs/rows-2.svg';
      case SailSVGAsset.iconMailX:
        return 'assets/svgs/mail-x.svg';
      case SailSVGAsset.iconMedal:
        return 'assets/svgs/medal.svg';
      case SailSVGAsset.iconMessageCircleCode:
        return 'assets/svgs/message-circle-code.svg';
      case SailSVGAsset.iconInspectionPanel:
        return 'assets/svgs/inspection-panel.svg';
      case SailSVGAsset.iconNotepadText:
        return 'assets/svgs/notepad-text.svg';
      case SailSVGAsset.iconMessageCircleX:
        return 'assets/svgs/message-circle-x.svg';
      case SailSVGAsset.iconArrowRightFromLine:
        return 'assets/svgs/arrow-right-from-line.svg';
      case SailSVGAsset.iconArrowLeft:
        return 'assets/svgs/arrow-left.svg';
      case SailSVGAsset.iconPaintbrush:
        return 'assets/svgs/paintbrush.svg';
      case SailSVGAsset.iconRows3:
        return 'assets/svgs/rows-3.svg';
      case SailSVGAsset.iconAlignCenter:
        return 'assets/svgs/align-center.svg';
      case SailSVGAsset.iconBadgeSwissFranc:
        return 'assets/svgs/badge-swiss-franc.svg';
      case SailSVGAsset.iconCross:
        return 'assets/svgs/cross.svg';
      case SailSVGAsset.iconSquareMinus:
        return 'assets/svgs/square-minus.svg';
      case SailSVGAsset.iconUniversity:
        return 'assets/svgs/university.svg';
      case SailSVGAsset.iconRoute:
        return 'assets/svgs/route.svg';
      case SailSVGAsset.iconCircleArrowUp:
        return 'assets/svgs/circle-arrow-up.svg';
      case SailSVGAsset.iconDiameter:
        return 'assets/svgs/diameter.svg';
      case SailSVGAsset.iconPcCase:
        return 'assets/svgs/pc-case.svg';
      case SailSVGAsset.iconEllipsis:
        return 'assets/svgs/ellipsis.svg';
      case SailSVGAsset.iconCalendarHeart:
        return 'assets/svgs/calendar-heart.svg';
      case SailSVGAsset.iconIconDropdown:
        return 'assets/svgs/icon_dropdown.svg';
      case SailSVGAsset.iconBookHeadphones:
        return 'assets/svgs/book-headphones.svg';
      case SailSVGAsset.iconArrowDownRight:
        return 'assets/svgs/arrow-down-right.svg';
      case SailSVGAsset.iconFileBox:
        return 'assets/svgs/file-box.svg';
      case SailSVGAsset.iconPawPrint:
        return 'assets/svgs/paw-print.svg';
      case SailSVGAsset.iconLaptop:
        return 'assets/svgs/laptop.svg';
      case SailSVGAsset.iconIconPeers:
        return 'assets/svgs/icon_peers.svg';
      case SailSVGAsset.iconPowerOff:
        return 'assets/svgs/power-off.svg';
      case SailSVGAsset.iconRedoDot:
        return 'assets/svgs/redo-dot.svg';
      case SailSVGAsset.iconAxis3d:
        return 'assets/svgs/axis-3d.svg';
      case SailSVGAsset.iconArrowBigUp:
        return 'assets/svgs/arrow-big-up.svg';
      case SailSVGAsset.iconFramer:
        return 'assets/svgs/framer.svg';
      case SailSVGAsset.iconKeyboardOff:
        return 'assets/svgs/keyboard-off.svg';
      case SailSVGAsset.iconMountain:
        return 'assets/svgs/mountain.svg';
      case SailSVGAsset.iconStretchHorizontal:
        return 'assets/svgs/stretch-horizontal.svg';
      case SailSVGAsset.iconBellDot:
        return 'assets/svgs/bell-dot.svg';
      case SailSVGAsset.iconClipboardX:
        return 'assets/svgs/clipboard-x.svg';
      case SailSVGAsset.iconFolderDown:
        return 'assets/svgs/folder-down.svg';
      case SailSVGAsset.iconShieldQuestion:
        return 'assets/svgs/shield-question.svg';
      case SailSVGAsset.iconPanelBottomDashed:
        return 'assets/svgs/panel-bottom-dashed.svg';
      case SailSVGAsset.iconVolumeX:
        return 'assets/svgs/volume-x.svg';
      case SailSVGAsset.iconMusic3:
        return 'assets/svgs/music-3.svg';
      case SailSVGAsset.iconCopySlash:
        return 'assets/svgs/copy-slash.svg';
      case SailSVGAsset.iconFileCode:
        return 'assets/svgs/file-code.svg';
      case SailSVGAsset.iconMoveLeft:
        return 'assets/svgs/move-left.svg';
      case SailSVGAsset.iconSlack:
        return 'assets/svgs/slack.svg';
      case SailSVGAsset.iconCircleDashed:
        return 'assets/svgs/circle-dashed.svg';
      case SailSVGAsset.iconClock2:
        return 'assets/svgs/clock-2.svg';
      case SailSVGAsset.iconUserRoundMinus:
        return 'assets/svgs/user-round-minus.svg';
      case SailSVGAsset.iconScissorsLineDashed:
        return 'assets/svgs/scissors-line-dashed.svg';
      case SailSVGAsset.iconFileOutput:
        return 'assets/svgs/file-output.svg';
      case SailSVGAsset.iconCloud:
        return 'assets/svgs/cloud.svg';
      case SailSVGAsset.iconHopOff:
        return 'assets/svgs/hop-off.svg';
      case SailSVGAsset.iconIconMelt:
        return 'assets/svgs/icon_melt.svg';
      case SailSVGAsset.iconClock11:
        return 'assets/svgs/clock-11.svg';
      case SailSVGAsset.iconShuffle:
        return 'assets/svgs/shuffle.svg';
      case SailSVGAsset.iconQuote:
        return 'assets/svgs/quote.svg';
      case SailSVGAsset.iconAnvil:
        return 'assets/svgs/anvil.svg';
      case SailSVGAsset.iconWashingMachine:
        return 'assets/svgs/washing-machine.svg';
      case SailSVGAsset.iconGripVertical:
        return 'assets/svgs/grip-vertical.svg';
      case SailSVGAsset.iconClock6:
        return 'assets/svgs/clock-6.svg';
      case SailSVGAsset.iconDrill:
        return 'assets/svgs/drill.svg';
      case SailSVGAsset.iconPlugZap2:
        return 'assets/svgs/plug-zap-2.svg';
      case SailSVGAsset.iconAlignHorizontalDistributeStart:
        return 'assets/svgs/align-horizontal-distribute-start.svg';
      case SailSVGAsset.iconFileType:
        return 'assets/svgs/file-type.svg';
      case SailSVGAsset.iconRewind:
        return 'assets/svgs/rewind.svg';
      case SailSVGAsset.iconWineOff:
        return 'assets/svgs/wine-off.svg';
      case SailSVGAsset.iconUpload:
        return 'assets/svgs/upload.svg';
      case SailSVGAsset.iconTrendingDown:
        return 'assets/svgs/trending-down.svg';
      case SailSVGAsset.iconDividerDot:
        return 'assets/svgs/divider_dot.svg';
      case SailSVGAsset.iconBookmarkCheck:
        return 'assets/svgs/bookmark-check.svg';
      case SailSVGAsset.iconFoldVertical:
        return 'assets/svgs/fold-vertical.svg';
      case SailSVGAsset.iconCalendarX:
        return 'assets/svgs/calendar-x.svg';
      case SailSVGAsset.iconPause:
        return 'assets/svgs/pause.svg';
      case SailSVGAsset.iconRadical:
        return 'assets/svgs/radical.svg';
      case SailSVGAsset.iconArrowBigUpDash:
        return 'assets/svgs/arrow-big-up-dash.svg';
      case SailSVGAsset.iconFolderKey:
        return 'assets/svgs/folder-key.svg';
      case SailSVGAsset.iconGrid2x2:
        return 'assets/svgs/grid-2x2.svg';
      case SailSVGAsset.iconCloudHail:
        return 'assets/svgs/cloud-hail.svg';
      case SailSVGAsset.iconSearchX:
        return 'assets/svgs/search-x.svg';
      case SailSVGAsset.iconCloudy:
        return 'assets/svgs/cloudy.svg';
      case SailSVGAsset.iconReplace:
        return 'assets/svgs/replace.svg';
      case SailSVGAsset.iconForward:
        return 'assets/svgs/forward.svg';
      case SailSVGAsset.iconMountainSnow:
        return 'assets/svgs/mountain-snow.svg';
      case SailSVGAsset.iconIconTools:
        return 'assets/svgs/icon_tools.svg';
      case SailSVGAsset.iconIndentDecrease:
        return 'assets/svgs/indent-decrease.svg';
      case SailSVGAsset.iconCircleMinus:
        return 'assets/svgs/circle-minus.svg';
      case SailSVGAsset.iconIconPendingHalf:
        return 'assets/svgs/icon_pending_half.svg';
      case SailSVGAsset.iconDices:
        return 'assets/svgs/dices.svg';
      case SailSVGAsset.iconBlend:
        return 'assets/svgs/blend.svg';
      case SailSVGAsset.iconBookmark:
        return 'assets/svgs/bookmark.svg';
      case SailSVGAsset.iconBraces:
        return 'assets/svgs/braces.svg';
      case SailSVGAsset.iconRocket:
        return 'assets/svgs/rocket.svg';
      case SailSVGAsset.iconCircleDot:
        return 'assets/svgs/circle-dot.svg';
      case SailSVGAsset.iconMoveRight:
        return 'assets/svgs/move-right.svg';
      case SailSVGAsset.iconDrama:
        return 'assets/svgs/drama.svg';
      case SailSVGAsset.iconAsterisk:
        return 'assets/svgs/asterisk.svg';
      case SailSVGAsset.iconUserCheck:
        return 'assets/svgs/user-check.svg';
      case SailSVGAsset.iconCalendarClock:
        return 'assets/svgs/calendar-clock.svg';
      case SailSVGAsset.iconFishOff:
        return 'assets/svgs/fish-off.svg';
      case SailSVGAsset.iconFolderSearch:
        return 'assets/svgs/folder-search.svg';
      case SailSVGAsset.iconFolderPen:
        return 'assets/svgs/folder-pen.svg';
      case SailSVGAsset.iconCloudSunRain:
        return 'assets/svgs/cloud-sun-rain.svg';
      case SailSVGAsset.iconGitPullRequestCreate:
        return 'assets/svgs/git-pull-request-create.svg';
      case SailSVGAsset.iconTablet:
        return 'assets/svgs/tablet.svg';
      case SailSVGAsset.iconMailCheck:
        return 'assets/svgs/mail-check.svg';
      case SailSVGAsset.iconAlignVerticalJustifyCenter:
        return 'assets/svgs/align-vertical-justify-center.svg';
      case SailSVGAsset.iconFileDiff:
        return 'assets/svgs/file-diff.svg';
      case SailSVGAsset.iconMonitorDot:
        return 'assets/svgs/monitor-dot.svg';
      case SailSVGAsset.iconTicketSlash:
        return 'assets/svgs/ticket-slash.svg';
      case SailSVGAsset.iconAlignHorizontalSpaceBetween:
        return 'assets/svgs/align-horizontal-space-between.svg';
      case SailSVGAsset.iconWebhook:
        return 'assets/svgs/webhook.svg';
      case SailSVGAsset.iconDiamondPercent:
        return 'assets/svgs/diamond-percent.svg';
      case SailSVGAsset.iconFolderOpenDot:
        return 'assets/svgs/folder-open-dot.svg';
      case SailSVGAsset.iconArrowLeftRight:
        return 'assets/svgs/arrow-left-right.svg';
      case SailSVGAsset.iconIconTabSettings:
        return 'assets/svgs/icon_tab_settings.svg';
      case SailSVGAsset.iconCodeXml:
        return 'assets/svgs/code-xml.svg';
      case SailSVGAsset.iconCloudDownload:
        return 'assets/svgs/cloud-download.svg';
      case SailSVGAsset.iconUtilityPole:
        return 'assets/svgs/utility-pole.svg';
      case SailSVGAsset.iconSignalZero:
        return 'assets/svgs/signal-zero.svg';
      case SailSVGAsset.iconBookUp2:
        return 'assets/svgs/book-up-2.svg';
      case SailSVGAsset.iconMonitorOff:
        return 'assets/svgs/monitor-off.svg';
      case SailSVGAsset.iconEar:
        return 'assets/svgs/ear.svg';
      case SailSVGAsset.iconSpellCheck:
        return 'assets/svgs/spell-check.svg';
      case SailSVGAsset.iconFileTerminal:
        return 'assets/svgs/file-terminal.svg';
      case SailSVGAsset.iconFlame:
        return 'assets/svgs/flame.svg';
      case SailSVGAsset.iconIconTabMeltCast:
        return 'assets/svgs/icon_tab_melt_cast.svg';
      case SailSVGAsset.iconGalleryHorizontalEnd:
        return 'assets/svgs/gallery-horizontal-end.svg';
      case SailSVGAsset.iconNutOff:
        return 'assets/svgs/nut-off.svg';
      case SailSVGAsset.iconComponent:
        return 'assets/svgs/component.svg';
      case SailSVGAsset.iconCircleOff:
        return 'assets/svgs/circle-off.svg';
      case SailSVGAsset.iconFileSearch2:
        return 'assets/svgs/file-search-2.svg';
      case SailSVGAsset.iconAlignStartHorizontal:
        return 'assets/svgs/align-start-horizontal.svg';
      case SailSVGAsset.iconLocateFixed:
        return 'assets/svgs/locate-fixed.svg';
      case SailSVGAsset.iconLockOpen:
        return 'assets/svgs/lock-open.svg';
      case SailSVGAsset.iconLoaderPinwheel:
        return 'assets/svgs/loader-pinwheel.svg';
      case SailSVGAsset.iconAtom:
        return 'assets/svgs/atom.svg';
      case SailSVGAsset.iconCat:
        return 'assets/svgs/cat.svg';
      case SailSVGAsset.iconCloudCog:
        return 'assets/svgs/cloud-cog.svg';
      case SailSVGAsset.iconSword:
        return 'assets/svgs/sword.svg';
      case SailSVGAsset.iconSquarePilcrow:
        return 'assets/svgs/square-pilcrow.svg';
      case SailSVGAsset.iconSquirrel:
        return 'assets/svgs/squirrel.svg';
      case SailSVGAsset.iconMenu:
        return 'assets/svgs/menu.svg';
      case SailSVGAsset.iconPinOff:
        return 'assets/svgs/pin-off.svg';
      case SailSVGAsset.iconLampCeiling:
        return 'assets/svgs/lamp-ceiling.svg';
      case SailSVGAsset.iconFolderDot:
        return 'assets/svgs/folder-dot.svg';
      case SailSVGAsset.iconUtensilsCrossed:
        return 'assets/svgs/utensils-crossed.svg';
      case SailSVGAsset.iconRatio:
        return 'assets/svgs/ratio.svg';
      case SailSVGAsset.iconSquareArrowDownLeft:
        return 'assets/svgs/square-arrow-down-left.svg';
      case SailSVGAsset.iconGrid2x2X:
        return 'assets/svgs/grid-2x2-x.svg';
      case SailSVGAsset.iconOctagonAlert:
        return 'assets/svgs/octagon-alert.svg';
      case SailSVGAsset.iconGalleryVertical:
        return 'assets/svgs/gallery-vertical.svg';
      case SailSVGAsset.iconImageMinus:
        return 'assets/svgs/image-minus.svg';
      case SailSVGAsset.iconClock7:
        return 'assets/svgs/clock-7.svg';
      case SailSVGAsset.iconArrowRightToLine:
        return 'assets/svgs/arrow-right-to-line.svg';
      case SailSVGAsset.iconAArrowDown:
        return 'assets/svgs/a-arrow-down.svg';
      case SailSVGAsset.iconMerge:
        return 'assets/svgs/merge.svg';
      case SailSVGAsset.iconMapPinned:
        return 'assets/svgs/map-pinned.svg';
      case SailSVGAsset.iconSquarePi:
        return 'assets/svgs/square-pi.svg';
      case SailSVGAsset.iconAlignHorizontalSpaceAround:
        return 'assets/svgs/align-horizontal-space-around.svg';
      case SailSVGAsset.iconChrome:
        return 'assets/svgs/chrome.svg';
      case SailSVGAsset.iconStickyNote:
        return 'assets/svgs/sticky-note.svg';
      case SailSVGAsset.iconTicketPlus:
        return 'assets/svgs/ticket-plus.svg';
      case SailSVGAsset.iconShoppingCart:
        return 'assets/svgs/shopping-cart.svg';
      case SailSVGAsset.iconCopyX:
        return 'assets/svgs/copy-x.svg';
      case SailSVGAsset.iconCalculator:
        return 'assets/svgs/calculator.svg';
      case SailSVGAsset.iconClock10:
        return 'assets/svgs/clock-10.svg';
      case SailSVGAsset.iconTrainFrontTunnel:
        return 'assets/svgs/train-front-tunnel.svg';
      case SailSVGAsset.iconClock12:
        return 'assets/svgs/clock-12.svg';
      case SailSVGAsset.iconApple:
        return 'assets/svgs/apple.svg';
      case SailSVGAsset.iconCircleChevronLeft:
        return 'assets/svgs/circle-chevron-left.svg';
      case SailSVGAsset.iconMouse:
        return 'assets/svgs/mouse.svg';
      case SailSVGAsset.iconFlaskConical:
        return 'assets/svgs/flask-conical.svg';
      case SailSVGAsset.iconPictureInPicture2:
        return 'assets/svgs/picture-in-picture-2.svg';
      case SailSVGAsset.iconPentagon:
        return 'assets/svgs/pentagon.svg';
      case SailSVGAsset.iconDiamondMinus:
        return 'assets/svgs/diamond-minus.svg';
      case SailSVGAsset.iconShieldCheck:
        return 'assets/svgs/shield-check.svg';
      case SailSVGAsset.iconArrowDown01:
        return 'assets/svgs/arrow-down-0-1.svg';
      case SailSVGAsset.iconMessageCircleReply:
        return 'assets/svgs/message-circle-reply.svg';
      case SailSVGAsset.iconCirclePause:
        return 'assets/svgs/circle-pause.svg';
      case SailSVGAsset.iconMails:
        return 'assets/svgs/mails.svg';
      case SailSVGAsset.iconClock5:
        return 'assets/svgs/clock-5.svg';
      case SailSVGAsset.iconRectangleHorizontal:
        return 'assets/svgs/rectangle-horizontal.svg';
      case SailSVGAsset.iconShoppingBasket:
        return 'assets/svgs/shopping-basket.svg';
      case SailSVGAsset.iconListFilter:
        return 'assets/svgs/list-filter.svg';
      case SailSVGAsset.iconReceiptText:
        return 'assets/svgs/receipt-text.svg';
      case SailSVGAsset.iconMusic4:
        return 'assets/svgs/music-4.svg';
      case SailSVGAsset.iconBookUser:
        return 'assets/svgs/book-user.svg';
      case SailSVGAsset.iconShieldBan:
        return 'assets/svgs/shield-ban.svg';
      case SailSVGAsset.iconArrowDownToDot:
        return 'assets/svgs/arrow-down-to-dot.svg';
      case SailSVGAsset.iconBuilding:
        return 'assets/svgs/building.svg';
      case SailSVGAsset.iconIconBitdrive:
        return 'assets/svgs/icon_bitdrive.svg';
      case SailSVGAsset.iconClipboardCopy:
        return 'assets/svgs/clipboard-copy.svg';
      case SailSVGAsset.iconAngry:
        return 'assets/svgs/angry.svg';
      case SailSVGAsset.iconLollipop:
        return 'assets/svgs/lollipop.svg';
      case SailSVGAsset.iconBetweenVerticalEnd:
        return 'assets/svgs/between-vertical-end.svg';
      case SailSVGAsset.iconHistory:
        return 'assets/svgs/history.svg';
      case SailSVGAsset.iconGavel:
        return 'assets/svgs/gavel.svg';
      case SailSVGAsset.iconFolder:
        return 'assets/svgs/folder.svg';
      case SailSVGAsset.iconDraftingCompass:
        return 'assets/svgs/drafting-compass.svg';
      case SailSVGAsset.iconAlignHorizontalDistributeCenter:
        return 'assets/svgs/align-horizontal-distribute-center.svg';
      case SailSVGAsset.iconFileLock:
        return 'assets/svgs/file-lock.svg';
      case SailSVGAsset.iconLayers2:
        return 'assets/svgs/layers-2.svg';
      case SailSVGAsset.iconUsers:
        return 'assets/svgs/users.svg';
      case SailSVGAsset.iconBoomBox:
        return 'assets/svgs/boom-box.svg';
      case SailSVGAsset.iconSlice:
        return 'assets/svgs/slice.svg';
      case SailSVGAsset.iconFolderGit:
        return 'assets/svgs/folder-git.svg';
      case SailSVGAsset.iconFingerprint:
        return 'assets/svgs/fingerprint.svg';
      case SailSVGAsset.iconFlagOff:
        return 'assets/svgs/flag-off.svg';
      case SailSVGAsset.iconMicVocal:
        return 'assets/svgs/mic-vocal.svg';
      case SailSVGAsset.iconCornerDownLeft:
        return 'assets/svgs/corner-down-left.svg';
      case SailSVGAsset.iconFileAxis3d:
        return 'assets/svgs/file-axis-3d.svg';
      case SailSVGAsset.iconBookOpenText:
        return 'assets/svgs/book-open-text.svg';
      case SailSVGAsset.iconTimer:
        return 'assets/svgs/timer.svg';
      case SailSVGAsset.iconGamepad:
        return 'assets/svgs/gamepad.svg';
      case SailSVGAsset.iconGitCommitHorizontal:
        return 'assets/svgs/git-commit-horizontal.svg';
      case SailSVGAsset.iconMonitor:
        return 'assets/svgs/monitor.svg';
      case SailSVGAsset.iconClipboardCheck:
        return 'assets/svgs/clipboard-check.svg';
      case SailSVGAsset.iconUnlink2:
        return 'assets/svgs/unlink-2.svg';
      case SailSVGAsset.iconSquareArrowOutDownRight:
        return 'assets/svgs/square-arrow-out-down-right.svg';
      case SailSVGAsset.iconMinus:
        return 'assets/svgs/minus.svg';
      case SailSVGAsset.iconHeartPulse:
        return 'assets/svgs/heart-pulse.svg';
      case SailSVGAsset.iconRows4:
        return 'assets/svgs/rows-4.svg';
      case SailSVGAsset.iconHeartHandshake:
        return 'assets/svgs/heart-handshake.svg';
      case SailSVGAsset.iconBedDouble:
        return 'assets/svgs/bed-double.svg';
      case SailSVGAsset.iconTextSearch:
        return 'assets/svgs/text-search.svg';
      case SailSVGAsset.iconAudioWaveform:
        return 'assets/svgs/audio-waveform.svg';
      case SailSVGAsset.iconNavigation2:
        return 'assets/svgs/navigation-2.svg';
      case SailSVGAsset.iconPaintBucket:
        return 'assets/svgs/paint-bucket.svg';
      case SailSVGAsset.iconChevronLeft:
        return 'assets/svgs/chevron-left.svg';
      case SailSVGAsset.iconMoveUp:
        return 'assets/svgs/move-up.svg';
      case SailSVGAsset.iconFilm:
        return 'assets/svgs/film.svg';
      case SailSVGAsset.iconMoon:
        return 'assets/svgs/moon.svg';
      case SailSVGAsset.iconSquareArrowLeft:
        return 'assets/svgs/square-arrow-left.svg';
      case SailSVGAsset.iconPanelBottomClose:
        return 'assets/svgs/panel-bottom-close.svg';
      case SailSVGAsset.iconWeight:
        return 'assets/svgs/weight.svg';
      case SailSVGAsset.iconShieldOff:
        return 'assets/svgs/shield-off.svg';
      case SailSVGAsset.iconLayers3:
        return 'assets/svgs/layers-3.svg';
      case SailSVGAsset.iconScaling:
        return 'assets/svgs/scaling.svg';
      case SailSVGAsset.iconCable:
        return 'assets/svgs/cable.svg';
      case SailSVGAsset.iconAccessibility:
        return 'assets/svgs/accessibility.svg';
      case SailSVGAsset.iconMoveUpRight:
        return 'assets/svgs/move-up-right.svg';
      case SailSVGAsset.iconWalletCards:
        return 'assets/svgs/wallet-cards.svg';
      case SailSVGAsset.iconBusFront:
        return 'assets/svgs/bus-front.svg';
      case SailSVGAsset.iconLampWallDown:
        return 'assets/svgs/lamp-wall-down.svg';
      case SailSVGAsset.iconMousePointer:
        return 'assets/svgs/mouse-pointer.svg';
      case SailSVGAsset.iconFileJson:
        return 'assets/svgs/file-json.svg';
      case SailSVGAsset.iconTrainFront:
        return 'assets/svgs/train-front.svg';
      case SailSVGAsset.iconCalendarMinus2:
        return 'assets/svgs/calendar-minus-2.svg';
      case SailSVGAsset.iconRibbon:
        return 'assets/svgs/ribbon.svg';
      case SailSVGAsset.iconSquareStack:
        return 'assets/svgs/square-stack.svg';
      case SailSVGAsset.iconFlipHorizontal:
        return 'assets/svgs/flip-horizontal.svg';
      case SailSVGAsset.iconGalleryHorizontal:
        return 'assets/svgs/gallery-horizontal.svg';
      case SailSVGAsset.iconNotebook:
        return 'assets/svgs/notebook.svg';
      case SailSVGAsset.iconStamp:
        return 'assets/svgs/stamp.svg';
      case SailSVGAsset.iconSquareSplitHorizontal:
        return 'assets/svgs/square-split-horizontal.svg';
      case SailSVGAsset.iconArrowUpDown:
        return 'assets/svgs/arrow-up-down.svg';
      case SailSVGAsset.iconIconTabTools:
        return 'assets/svgs/icon_tab_tools.svg';
      case SailSVGAsset.iconScreenShare:
        return 'assets/svgs/screen-share.svg';
      case SailSVGAsset.iconCalendarDays:
        return 'assets/svgs/calendar-days.svg';
      case SailSVGAsset.iconAlignLeft:
        return 'assets/svgs/align-left.svg';
      case SailSVGAsset.iconSeparatorHorizontal:
        return 'assets/svgs/separator-horizontal.svg';
      case SailSVGAsset.iconFerrisWheel:
        return 'assets/svgs/ferris-wheel.svg';
      case SailSVGAsset.iconSofa:
        return 'assets/svgs/sofa.svg';
      case SailSVGAsset.iconClock4:
        return 'assets/svgs/clock-4.svg';
      case SailSVGAsset.iconTicketCheck:
        return 'assets/svgs/ticket-check.svg';
      case SailSVGAsset.iconCherry:
        return 'assets/svgs/cherry.svg';
      case SailSVGAsset.iconHeart:
        return 'assets/svgs/heart.svg';
      case SailSVGAsset.iconTrendingUp:
        return 'assets/svgs/trending-up.svg';

      case SailSVGAsset.iconTabPeg:
        return 'assets/svgs/icon_tab_peg.svg';
      case SailSVGAsset.iconTabBMM:
        return 'assets/svgs/icon_tab_bmm.svg';
      case SailSVGAsset.iconTabWithdrawalExplorer:
        return 'assets/svgs/icon_tab_withdrawal_explorer.svg';

      case SailSVGAsset.iconTabSidechainSend:
        return 'assets/svgs/icon_tab_send.svg';

      case SailSVGAsset.iconTabZCashMeltCast:
        return 'assets/svgs/icon_tab_melt_cast.svg';
      case SailSVGAsset.iconTabZCashShieldDeshield:
        return 'assets/svgs/icon_tab_shield_deshield.svg';
      case SailSVGAsset.iconTabZCashOperationStatuses:
        return 'assets/svgs/icon_tab_operation_statuses.svg';

      case SailSVGAsset.iconTabConsole:
        return 'assets/svgs/icon_tab_console.svg';
      case SailSVGAsset.iconTabSettings:
        return 'assets/svgs/icon_tab_settings.svg';
      case SailSVGAsset.iconTabTools:
        return 'assets/svgs/icon_tab_tools.svg';
      case SailSVGAsset.iconTabStarters:
        return 'assets/svgs/icon_tab_starters.svg';

      case SailSVGAsset.iconCalendar:
        return 'assets/svgs/icon_calendar.svg';
      case SailSVGAsset.iconQuestion:
        return 'assets/svgs/icon_question.svg';
      case SailSVGAsset.iconSearch:
        return 'assets/svgs/icon_search.svg';
      case SailSVGAsset.iconCopy:
        return 'assets/svgs/icon_copy.svg';
      case SailSVGAsset.iconRestart:
        return 'assets/svgs/icon_restart.svg';
      case SailSVGAsset.iconArrow:
        return 'assets/svgs/icon_arrow_down.svg';
      case SailSVGAsset.iconArrowForward:
        return 'assets/svgs/icon_arrow_forward.svg';
      case SailSVGAsset.iconClose:
        return 'assets/svgs/icon_close.svg';
      case SailSVGAsset.iconGlobe:
        return 'assets/svgs/icon_globe.svg';
      case SailSVGAsset.iconExpand:
        return 'assets/svgs/icon_expand.svg';
      case SailSVGAsset.iconDropdown:
        return 'assets/svgs/icon_dropdown.svg';
      case SailSVGAsset.iconDeposit:
        return 'assets/svgs/icon_deposit.svg';
      case SailSVGAsset.iconWithdraw:
        return 'assets/svgs/icon_withdraw.svg';

      case SailSVGAsset.iconFormat:
        return 'assets/svgs/icon_format.svg';
      case SailSVGAsset.iconMelt:
        return 'assets/svgs/icon_melt.svg';
      case SailSVGAsset.iconCast:
        return 'assets/svgs/icon_cast.svg';
      case SailSVGAsset.iconTerminal:
        return 'assets/svgs/icon_terminal.svg';
      case SailSVGAsset.iconNetwork:
        return 'assets/svgs/icon_network.svg';
      case SailSVGAsset.iconPeers:
        return 'assets/svgs/icon_peers.svg';
      case SailSVGAsset.iconPen:
        return 'assets/svgs/icon_pen.svg';
      case SailSVGAsset.iconCheck:
        return 'assets/svgs/icon_check.svg';
      case SailSVGAsset.iconNewWindow:
        return 'assets/svgs/icon_new_window.svg';
      case SailSVGAsset.iconTools:
        return 'assets/svgs/icon_tools.svg';

      case SailSVGAsset.iconHome:
        return 'assets/svgs/icon_home.svg';
      case SailSVGAsset.iconSend:
        return 'assets/svgs/icon_send.svg';
      case SailSVGAsset.iconReceive:
        return 'assets/svgs/icon_receive.svg';
      case SailSVGAsset.iconTransactions:
        return 'assets/svgs/icon_transactions.svg';
      case SailSVGAsset.iconSidechains:
        return 'assets/svgs/icon_sidechains.svg';
      case SailSVGAsset.iconLearn:
        return 'assets/svgs/icon_learn.svg';

      case SailSVGAsset.iconSuccess:
        return 'assets/svgs/icon_success.svg';
      case SailSVGAsset.iconPending:
        return 'assets/svgs/icon_pending.svg';
      case SailSVGAsset.iconPendingHalf:
        return 'assets/svgs/icon_pending_half.svg';
      case SailSVGAsset.iconFailed:
        return 'assets/svgs/icon_failed.svg';
      case SailSVGAsset.iconInfo:
        return 'assets/svgs/icon_info.svg';
      case SailSVGAsset.iconSelected:
        return 'assets/svgs/icon_selected.svg';
      case SailSVGAsset.iconCoins:
        return 'assets/svgs/icon_coins.svg';
      case SailSVGAsset.iconConnectionStatus:
        return 'assets/svgs/icon_connection_status.svg';
      case SailSVGAsset.iconWarning:
        return 'assets/svgs/icon_warning.svg';
      case SailSVGAsset.iconWallet:
        return 'assets/svgs/icon_wallet.svg';
      case SailSVGAsset.iconCoinnews:
        return 'assets/svgs/icon_coinnews.svg';
      case SailSVGAsset.iconDelete:
        return 'assets/svgs/icon_delete.svg';
      case SailSVGAsset.iconMultisig:
        return 'assets/svgs/icon_multisig.svg';
      case SailSVGAsset.iconBitdrive:
        return 'assets/svgs/icon_bitdrive.svg';
      case SailSVGAsset.iconHDWallet:
        return 'assets/svgs/icon_hdwallet.svg';

      case SailSVGAsset.iconLightMode:
        return 'assets/svgs/icon_light_mode.svg';
      case SailSVGAsset.iconDarkMode:
        return 'assets/svgs/icon_dark_mode.svg';
      case SailSVGAsset.iconLightDarkMode:
        return 'assets/svgs/icon_light_dark_mode.svg';

      case SailSVGAsset.meltCastDiagram:
        return 'assets/pngs/meltcastdiagram.png';

      case SailSVGAsset.dividerDot:
        return 'assets/svgs/divider_dot.svg';
    }
  }
}

extension PNGAsAssetPath on SailPNGAsset {
  String toAssetPath() {
    switch (this) {
      case SailPNGAsset.meltCastDiagram:
        return 'assets/pngs/meltcastdiagram.png';
      case SailPNGAsset.articleBeginner:
        return 'assets/pngs/article-beginner.png';
    }
  }
}
