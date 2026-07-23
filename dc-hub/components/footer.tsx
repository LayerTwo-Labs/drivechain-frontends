import { SiGithub, SiReddit, SiTelegram, SiX, SiYoutube } from "@icons-pack/react-simple-icons";
import Image from "next/image";
import Link from "next/link";

export function Footer() {
  return (
    <footer className="w-full bg-black text-white py-12 mt-auto">
      <div className="container mx-auto flex flex-col items-center gap-6 px-4">
        {/* Logo */}
        <Link href="https://layertwolabs.com" target="_blank" className="flex items-center gap-2">
          <Image src="/logo.png" width={160} height={32} alt="LayerTwo Labs" className="h-8" />
        </Link>

        {/* Social Icons */}
        <div className="flex items-center gap-6 flex-wrap justify-center">
          <Link
            href="https://twitter.com/LayerTwoLabs"
            target="_blank"
            className="hover:text-gray-300 transition-colors"
          >
            <SiX className="h-6 w-6 fill-current" />
          </Link>
          <Link
            href="https://www.youtube.com/@LayerTwoLabs"
            target="_blank"
            className="hover:text-gray-300 transition-colors"
          >
            <SiYoutube className="h-6 w-6 fill-current" />
          </Link>
          <Link
            href="https://t.me/DcInsiders"
            target="_blank"
            className="hover:text-gray-300 transition-colors"
          >
            <SiTelegram className="h-6 w-6 fill-current" />
          </Link>
          <Link
            href="https://github.com/LayerTwo-Labs"
            target="_blank"
            className="hover:text-gray-300 transition-colors"
          >
            <SiGithub className="h-6 w-6 fill-current" />
          </Link>
          <Link
            href="https://www.reddit.com/r/Drivechains"
            target="_blank"
            className="hover:text-gray-300 transition-colors"
          >
            <SiReddit className="h-6 w-6 fill-current" />
          </Link>
        </div>

        {/* Copyright */}
        <div className="text-gray-400 text-sm text-center">
          Copyright ©{new Date().getFullYear()} LayerTwo Labs, Inc. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
