import React from "react";
import Svg, { Path, Defs, LinearGradient, Stop, Circle } from "react-native-svg";

export default function LotusIcon({ size = 32, glow = false }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 60 52" fill="none">
      <Path d="M30 48 C30 48 12 36 12 22 C12 14 20 8 30 8 C40 8 48 14 48 22 C48 36 30 48 30 48Z" fill="url(#lp1)" opacity={0.85}/>
      <Path d="M30 48 C30 48 8 42 5 28 C3 18 10 10 20 12 C26 13 30 20 30 28" fill="url(#lp2)" opacity={0.7}/>
      <Path d="M30 48 C30 48 52 42 55 28 C57 18 50 10 40 12 C34 13 30 20 30 28" fill="url(#lp3)" opacity={0.7}/>
      <Path d="M30 8 L30 2" stroke="#f7e08a" strokeWidth={1.5} strokeLinecap="round"/>
      <Circle cx={30} cy={2} r={2} fill="#f7e08a" opacity={0.9}/>
      <Defs>
        <LinearGradient id="lp1" x1={30} y1={8} x2={30} y2={48} gradientUnits="userSpaceOnUse">
          <Stop stopColor="#c9bef7" />
          <Stop offset={1} stopColor="#7c9abf" />
        </LinearGradient>
        <LinearGradient id="lp2" x1={5} y1={10} x2={30} y2={48} gradientUnits="userSpaceOnUse">
          <Stop stopColor="#7c9abf" />
          <Stop offset={1} stopColor="#4a7a8a" />
        </LinearGradient>
        <LinearGradient id="lp3" x1={55} y1={10} x2={30} y2={48} gradientUnits="userSpaceOnUse">
          <Stop stopColor="#7c9abf" />
          <Stop offset={1} stopColor="#4a7a8a" />
        </LinearGradient>
      </Defs>
    </Svg>
  );
}
