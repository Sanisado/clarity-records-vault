# Clarity 2.0 Smart Contract: Vault Records

This smart contract is designed for managing and securing vault records with functionalities such as record creation, sharing, updating, deletion, and access control. It allows users to create records with specific metadata, securely share them with others, and grant or revoke access to those records with different access levels.

## Table of Contents
- [Contract Overview](#contract-overview)
- [Key Concepts](#key-concepts)
- [Installation and Setup](#installation-and-setup)
- [Public Functions](#public-functions)
- [Private Functions](#private-functions)
- [Error Handling](#error-handling)
- [Example Usage](#example-usage)
- [Contributors](#contributors)

## Contract Overview

The Vault Records smart contract allows users to store, update, share, and delete records in a decentralized vault. Each record is identified by a unique ID and contains metadata, a content hash, and attributes. Access to each record can be granted to other users with specific access levels and durations. The contract supports various functions for managing these records and enforcing role-based access control.

## Key Concepts

- **Vault Records**: Data entries that contain metadata and content information. Each record is assigned a unique `record-id`.
- **Access Levels**: Defines the permissions granted to users. Valid access levels include `read`, `write`, and `admin`.
- **Metadata**: Additional information about a record such as tags, categories, or other descriptive attributes.
- **Attributes**: A set of specific properties that define each record, such as format, content type, etc.
- **Permissions**: Users can be granted specific access to records with controlled read/write capabilities.

### Constants:
- **ERR_UNAUTHORIZED**: Error returned for unauthorized actions.
- **ERR_INVALID_INPUT**: Error for invalid input parameters.
- **ERR_RECORD_NOT_FOUND**: Error when a requested record does not exist.
- **ERR_RECORD_EXISTS**: Error when attempting to create a record that already exists.
- **ERR_INVALID_METADATA**: Error when metadata is invalid.
- **ERR_PERMISSION_DENIED**: Error when a user does not have permission to access or modify a record.
- **SYSTEM_OWNER**: The address that owns the system, typically the contract deployer.

### Data Structures:
- **Vault Records**: Stores records with attributes like `title`, `owner`, `content-hash`, `metadata`, `category`, and `attributes`.
- **Record Sharing**: Manages the sharing permissions of records, including access levels (`read`, `write`, `admin`) and validity duration.

## Installation and Setup

1. Install [Clarinet](https://docs.claritylang.org/getting-started) and ensure it's properly configured.
2. Clone this repository and navigate to the project directory:
   ```bash
   git clone https://github.com/yourusername/vault-records.git
   cd vault-records
   ```
3. Deploy the smart contract using Clarinet CLI:
   ```bash
   clarinet deploy
   ```
4. Interact with the contract using the Clarinet console or integrate it with a front-end application.

## Public Functions

### 1. `create-record`
Creates a new record in the vault.

#### Parameters:
- `title`: Title of the record (string, up to 50 characters).
- `content-hash`: Hash representing the content of the record (string, 64 characters).
- `metadata`: Additional metadata describing the record (string, up to 200 characters).
- `category`: Category to classify the record (string, up to 20 characters).
- `attributes`: List of attributes for the record (up to 5 attributes, each up to 30 characters).

#### Returns:
- The `record-id` of the newly created record.

### 2. `update-record`
Updates an existing record.

#### Parameters:
- `record-id`: The unique ID of the record to update.
- `new-title`: New title for the record.
- `new-content-hash`: New content hash for the record.
- `new-metadata`: Updated metadata for the record.
- `new-attributes`: Updated attributes for the record.

#### Returns:
- `true` if the update is successful.

### 3. `share-record`
Shares a record with another user.

#### Parameters:
- `record-id`: The ID of the record to share.
- `recipient`: The principal (address) of the user to share the record with.
- `access-level`: The access level (`read`, `write`, `admin`).
- `duration`: Duration for which the access is valid (in blocks).
- `can-modify`: Whether the recipient can modify the record.

#### Returns:
- `true` if the sharing was successful.

### 4. `revoke-access`
Revokes access to a shared record for a user.

#### Parameters:
- `record-id`: The ID of the record.
- `user`: The principal (address) of the user whose access is to be revoked.

#### Returns:
- `true` if the revocation is successful.

### 5. `delete-record`
Deletes a record from the vault.

#### Parameters:
- `record-id`: The ID of the record to delete.

#### Returns:
- `true` if the record is deleted.

### 6. `get-record-by-id`
Fetches a record by its unique ID.

#### Parameters:
- `record-id`: The ID of the record.

#### Returns:
- The record details if found, or an error if not.

## Private Functions

Private functions are used internally for validation and various helper tasks. These include:
- `validate-record-title`: Ensures the title is valid.
- `validate-content-hash`: Validates the content hash.
- `validate-metadata`: Validates the metadata.
- `validate-access-level`: Ensures the access level is valid.
- `is-record-owner`: Checks if the sender is the owner of a record.

## Error Handling

The contract uses specific error codes to handle exceptions:
- **ERR_UNAUTHORIZED**: Unauthorized action (e.g., trying to update or delete a record without ownership).
- **ERR_INVALID_INPUT**: Invalid input parameters (e.g., incorrect data types or out-of-bound values).
- **ERR_RECORD_NOT_FOUND**: When a record cannot be found for a given ID.
- **ERR_INVALID_METADATA**: Metadata that does not meet the requirements.

## Example Usage

### Create a Record
```clojure
(create-record "Sample Title" "hash-of-content" "Sample metadata" "category1" ["attr1", "attr2"])
```

### Update a Record
```clojure
(update-record 1 "Updated Title" "new-hash" "Updated metadata" ["new-attr1", "new-attr2"])
```

### Share a Record
```clojure
(share-record 1 recipient-address "read" 10000 true)
```

### Revoke Access
```clojure
(revoke-access 1 recipient-address)
```

### Delete a Record
```clojure
(delete-record 1)
```

## Contributors

- [Your Name](https://github.com/yourusername) - Contract author and maintainer.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```