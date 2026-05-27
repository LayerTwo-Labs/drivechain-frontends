import Link from "next/link";
import { instanceNetwork } from "@/lib/utils";

export function Footer() {
  return (
    <footer className="footer">
      <div className="container footer__inner">
        <span className="label">{instanceNetwork()}</span>
        <Link href="https://github.com/LayerTwo-Labs/sidesail" target="_blank" className="label">
          Github ›
        </Link>
      </div>
    </footer>
  );
}
