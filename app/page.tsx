"use client"; // This page interacts with browser APIs (wallet), so it needs to be a Client Component

import * as React from "react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { Button } from "@/components/ui/button";
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { parseEther } from "viem";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Terminal } from "lucide-react";

// --- Contract Configuration ---
// TODO: Replace with your actual contract address deployed on Anvil
const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Default Anvil deployment address

// Minimal ABI for the buyTokens function
const contractABI = [
  {
    "type": "function",
    "name": "buyTokens",
    "inputs": [],
    "outputs": [],
    "stateMutability": "payable"
  },
] as const; // Use 'as const' for better type inference with Viem/Wagmi

const TOKEN_PRICE_ETH = "0.1"; // The price of one token in ETH

export default function Home() {
  const { address, isConnected } = useAccount();
  const { data: hash, error, isPending, writeContract } = useWriteContract();

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  const handleBuyToken = () => {
    if (!isConnected) {
      // Although the button should be disabled, add an extra check
      alert("Please connect your wallet first.");
      return;
    }
    writeContract({
      address: contractAddress,
      abi: contractABI,
      functionName: "buyTokens",
      value: parseEther(TOKEN_PRICE_ETH), // Send 0.1 ETH
    });
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-gray-900 text-white p-4 font-[family-name:var(--font-geist-sans)]">
      <header className="absolute top-4 right-4">
        <ConnectButton />
      </header>

      <main className="flex flex-col items-center gap-8 text-center max-w-2xl">
        {/* Optional: Add a cool logo or graphic here */}
        {/* <Image src="/logo.svg" alt="Aider Logo" width={150} height={150} className="mb-4" /> */}

        <h1 className="text-5xl sm:text-6xl font-bold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-purple-400 via-pink-500 to-red-500">
          AIDER Token Sale
        </h1>

        <p className="text-lg text-gray-300">
          Get your AID tokens now! Each token costs {TOKEN_PRICE_ETH} ETH.{" "}
          <br />
          Built with AI, powered by the community.
        </p>

        {isConnected ? (
          <div className="flex flex-col items-center gap-4 w-full max-w-sm">
            {/* <p className="text-sm text-gray-400">Connected: {address}</p> */}
            <Button
              onClick={handleBuyToken}
              disabled={isPending || isConfirming}
              size="lg"
              className="w-full bg-purple-600 hover:bg-purple-700 text-white font-semibold text-lg py-3 px-6 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isPending || isConfirming ? "Processing..." : `Buy 1 AID Token for ${TOKEN_PRICE_ETH} ETH`}
            </Button>

            {/* Transaction Status Display */}
            {hash && !isConfirmed && !error && (
              <Alert variant="default" className="bg-blue-900/50 border-blue-700 text-blue-200">
                <Terminal className="h-4 w-4 !text-blue-300" />
                <AlertTitle>Transaction Sent</AlertTitle>
                <AlertDescription>
                  Waiting for confirmation... Hash:{" "}
                  <a
                    href={`http://localhost:8545/tx/${hash}`} // Anvil doesn't have a block explorer, link might not work directly
                    target="_blank"
                    rel="noopener noreferrer"
                    className="underline hover:text-blue-100 break-all"
                  >
                    {hash.substring(0, 10)}...{hash.substring(hash.length - 8)}
                  </a>
                </AlertDescription>
              </Alert>
            )}
            {isConfirmed && (
              <Alert variant="default" className="bg-green-900/50 border-green-700 text-green-200">
                 <Terminal className="h-4 w-4 !text-green-300" />
                <AlertTitle>Success!</AlertTitle>
                <AlertDescription>
                  Token purchase confirmed! Transaction Hash:{" "}
                   <a
                    href={`http://localhost:8545/tx/${hash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="underline hover:text-green-100 break-all"
                  >
                     {hash.substring(0, 10)}...{hash.substring(hash.length - 8)}
                  </a>
                </AlertDescription>
              </Alert>
            )}
             {error && (
              <Alert variant="destructive">
                 <Terminal className="h-4 w-4" />
                <AlertTitle>Error</AlertTitle>
                {/* Displaying the full error can be long, consider summarizing */}
                <AlertDescription className="break-words">
                  {error?.shortMessage || error.message}
                </AlertDescription>
              </Alert>
            )}
          </div>
        ) : (
          <p className="text-yellow-400 text-lg">
            Please connect your wallet to purchase tokens.
          </p>
        )}
      </main>

      <footer className="absolute bottom-4 text-xs text-gray-500">
        Powered by Next.js, Tailwind CSS, Shadcn UI, RainbowKit, Wagmi, Viem & Foundry
      </footer>
    </div>
  );
}
