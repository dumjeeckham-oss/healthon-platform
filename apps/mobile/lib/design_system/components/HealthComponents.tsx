import type { ButtonHTMLAttributes, HTMLAttributes, ReactNode } from "react";
import "../tokens/tokens.css";
import "./health-components.css";
export function HealthButton({variant="primary",...props}:ButtonHTMLAttributes<HTMLButtonElement>&{variant?:"primary"|"secondary"|"danger"|"ghost"}){return <button className={`health-button health-button--${variant}`} {...props}/>}
export function HealthCard({children,...props}:HTMLAttributes<HTMLDivElement>&{children:ReactNode}){return <section className="health-card" {...props}>{children}</section>}
export function HealthProgress({value,label="진행률"}:{value:number;label?:string}){return <div className="health-progress" role="progressbar" aria-label={label} aria-valuenow={value} aria-valuemin={0} aria-valuemax={100}><span style={{width:`${Math.max(0,Math.min(100,value))}%`}}/></div>}
export const componentNames=["HealthButton","HealthCard","HealthDialog","HealthProgress","HealthBadge","HealthTree","HealthSpecies","HealthWeather","HealthAvatar","HealthBottomSheet","HealthSnackbar","HealthSeasonBackground"] as const;
