#!/usr/bin/env python3

import os
import json
from semantic_version.base import Version
from solcx import compile_standard
from web3 import Web3
from dotenv import load_dotenv
from web3.types import Nonce

load_dotenv()

# Read solidity source file
with open("./contracts/SimpleStorage.sol", "r") as f:
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
with open("compiled.json", "w") as f:
    json.dump(compiled_sol, f)

# Extract bytecode and ABI
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"]["bytecode"]["object"]
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# Ganache connection
w3 = Web3(Web3.HTTPProvider(os.getenv("WEB3_CONNECTION")))
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
print("Transaction Built")

# Sign transaction
signed_transaction = w3.eth.account.sign_transaction(transaction, private_key=private_key)
print("Signed Transaction")

# Send transaction
transaction_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
print(f"Transaction Hash: {transaction_hash}")
transaction_receipt = w3.eth.wait_for_transaction_receipt(transaction_hash)
print("Transaction Complete. Contract deployed!")

###################

# Working with contracts require:
# * Contract ABI
# * Contract Address
simple_storage = w3.eth.contract(address=transaction_receipt["contractAddress"], abi=abi)

# 2 ways to interact:
# * Call -> Simulate making the call and getting a return value
# * Transact -> Actually make a state change. Can also be performed on views or pure functions

# Call
print("\nCall (retrieve(), store(15), retrieve()):")
print(simple_storage.functions.retrieve().call())
print(simple_storage.functions.store(15).call())
print(simple_storage.functions.retrieve().call())

# Transact
print("\nTransact (retrieve(), store(15), retrieve()):")
print(simple_storage.functions.retrieve().call())

store_transaction = simple_storage.functions.store(15).buildTransaction(
    {"chainId": chain_id, "from": str(address), "nonce": Nonce(nonce + 1)}
)  # build
signed_store_transaction = w3.eth.account.sign_transaction(store_transaction, private_key=private_key)  # sign
store_transaction_hash = w3.eth.send_raw_transaction(signed_store_transaction.rawTransaction)  # send
store_transaction_receipt = w3.eth.wait_for_transaction_receipt(store_transaction_hash)  # wait
print("Stored 15")

print(simple_storage.functions.retrieve().call())
