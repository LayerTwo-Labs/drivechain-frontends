import type * as React from "react";
import { cn } from "@/lib/utils";

export const Card: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ className, ...props }) => (
  <div
    className={cn("rounded-xl border bg-card text-card-foreground shadow", className)}
    {...props}
  />
);
Card.displayName = "Card";

export const CardHeader: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({
  className,
  ...props
}) => <div className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />;
CardHeader.displayName = "CardHeader";

export const CardTitle: React.FC<React.HTMLAttributes<HTMLHeadingElement>> = ({
  className,
  ...props
}) => <h3 className={cn("font-semibold leading-none tracking-tight", className)} {...props} />;
CardTitle.displayName = "CardTitle";

export const CardDescription: React.FC<React.HTMLAttributes<HTMLParagraphElement>> = ({
  className,
  ...props
}) => <p className={cn("text-sm text-muted-foreground", className)} {...props} />;
CardDescription.displayName = "CardDescription";

export const CardContent: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({
  className,
  ...props
}) => <div className={cn("p-6 pt-0", className)} {...props} />;
CardContent.displayName = "CardContent";

export const CardFooter: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({
  className,
  ...props
}) => <div className={cn("flex items-center p-6 pt-0", className)} {...props} />;
CardFooter.displayName = "CardFooter";
