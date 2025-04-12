"use client"; // This file needs to be a client component

import * as React from "react";
import {
  RainbowKitProvider,
  getDefaultConfig,
  darkTheme, // Optional: Or lightTheme, midnightTheme
} from "@rainbow-me/rainbowkit";
import { WagmiProvider } from "wagmi";
import { anvil } from "wagmi/chains"; // Import the anvil chain
import { QueryClientProvider, QueryClient } from "@tanstack/react-query";

// Get projectId from WalletConnect Cloud (https://cloud.walletconnect.com/)
// It's recommended to store this in an environment variable
const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID;

if (!projectId) {
  // In a real app, you might want to throw an error or handle this case more gracefully
  console.error("Error: NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID is not set.");
  // Using a placeholder to allow the app to run, but WalletConnect will likely fail.
  // throw new Error("NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID is not set.");
}

const config = getDefaultConfig({
  appName: "AIDER Token Sale",
  projectId: projectId || "YOUR_PROJECT_ID", // Fallback, but should be set via env var
  chains: [anvil], // Configure for Anvil local network
  ssr: true, // Enable SSR server side rendering (optional)
});

const queryClient = new QueryClient();

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
            theme={darkTheme({ // Optional: customize theme
                accentColor: '#7b3fe4',
                accentColorForeground: 'white',
                borderRadius: 'medium',
            })}
        >
            {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
