# Aider Smart Contract & Next.js Frontend Test Project

This project demonstrates using Aider, an AI pair programmer, to develop both a simple ERC20 smart contract (`AiderToken`) using Foundry and a Next.js frontend to interact with it.

The goal was to test Aider's capabilities in generating, modifying, and explaining code for both Solidity and TypeScript/React within a typical Web3 development workflow.

**Watch the Video Walkthrough:** [Link to YouTube Video - Coming Soon!]

**Read the Step-by-Step Guide:** [Link to Blog Post/Walkthrough - Coming Soon!]

## Project Structure

*   `/app`: Contains the Next.js frontend application.
*   `/contracts`: Contains the Solidity smart contract, tests, and deployment scripts managed with Foundry.

## Frontend (Next.js App)

The frontend allows users to connect their wallet (using RainbowKit and Wagmi) and purchase `AIDER` tokens from the deployed smart contract.

### Getting Started with the Frontend

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the frontend page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

See the `contracts/README.md` for instructions on how to compile, test, and deploy the smart contract locally using Anvil before running the frontend. You will need to update the contract address in `app/page.tsx` after deployment.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.
