#!/usr/bin/env python3

import os
import json
from semantic_version.base import Version
from solcx import compile_standard
from web3 import Web3
from dotenv import load_dotenv

load_dotenv()

# Read solidity source file
with open("./SimpleStorage.sol", "r") as f:
    data = f.read()

# Compile
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": data}},
        "settings": {"outputSelection": {"*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}}},
    },
    solc_version=Version("0.8.13"),
    solc_binary="/usr/bin/solc",
)

# Save
print(compiled_sol)
with open("compiled.json", "w") as f:
    json.dump(compiled_sol, f)

# Extract bytecode and ABI
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"]["bytecode"]["object"]
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# Ganache connection
w3 = Web3(Web3.HTTPProvider("http://172.25.224.1:7545"))
chain_id = 1337
address = os.getenv("WEB3_PUBLIC_ADDRESS")
private_key = os.getenv("WEB3_PRIVATE_KEY")

# Create contract in Python
simpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)

# Get nonce
nonce = w3.eth.get_transaction_count(address)
print(f"Nonce: {nonce}")

# Build transaction
transaction = simpleStorage.constructor().buildTransaction(
    {"gasPrice": w3.eth.gasPrice, "chainId": chain_id, "from": address, "nonce": nonce}
)
print(f"Transaction: {transaction}")

# Sign transaction
signed_transaction = w3.eth.account.sign_transaction(transaction, private_key=private_key)
print(f"Signed Transaction: {signed_transaction}")

# Send transaction
transaction_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
print(f"Transaction Hash: {transaction_hash}")
transaction_receipt = w3.eth.wait_for_transaction_receipt(transaction_hash)
print("Transaction Complete")
