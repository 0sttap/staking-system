## Getting Started

### Requirements

The following will need to be installed in order to use this. Please follow the links and instructions.

-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
    -   You'll know you've done it right if you can run `git --version`
-   [NodeJS](https://nodejs.org/en/download/package-manager)
    -   Check that Node is installed by running: `node --version` and get an output like: `v18.16.1`
-   [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
    -   Install Foundry by running the following command:
        ```sh
        curl -L https://foundry.paradigm.xyz | bash
        ```
    -   Initialize Foundry by running:
        ```sh
        foundryup
        ```
    -   Verify installation by running: `forge --version`
-   [Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
    -   Install Cargo by running the following command:
        ```sh
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        ```
    -   Follow the on-screen instructions to complete the installation.
    -   Verify installation by running: `cargo --version`

### Quickstart

#### 1. Clone this repo

```shell
git clone https://github.com/0sttap/staking-system.git
cd staking-system
```

#### 2. Install dependencies

Once you've cloned and entered into your repository, you need to install the necessary dependencies. In order to do so, simply run:

```shell
npm run install-dep
```

#### 3. Initialize .env files, you can create .env file or just rename `.env.example` to .env
 3.1 Initialize in `backend` folder
 3.2 Initialize in `contracts` folder

*You can use contracts addresses in `.env.example` if you won`t deploy new

#### 4. Test contracts

```shell
npm run test-contracts
```

#### 5. Deploy contracts

```shell
npm run deploy-contracts
```

*If you wont to interact with your new contracts you should change them inside `.env` files (backend and contracts folders)

#### 6. Start node server

```shell
npm run server-start
```

#### 7. Interact with contract

Stake:

```shell
npm run stake
```

Withdraw:

```shell
npm run withdraw
```

Distribute:

```shell
npm run distribute
```

Claim:

```shell
npm run claim
```
