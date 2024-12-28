;; Smart Contract: Clarity Record Vault 
;; 
;; Description:
;; This smart contract provides a robust system for securely managing records on a blockchain.
;; Key features include:
;; - Creating, updating, and deleting records with metadata, categories, and attributes.
;; - Sharing records with specified access levels (read, write, admin) and customizable durations.
;; - Validating inputs such as record titles, metadata, categories, and access levels.
;; - Supporting fine-grained permission control and record ownership verification.
;; - Ensuring secure record access and modification through rigorous validation checks.
;; 
;; The contract is designed for use cases where data security, integrity, and controlled sharing
;; are paramount, enabling decentralized, trusted management of sensitive records.
;;
;; Author: Sani Sado
;; Version: 2.0

;; Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_INPUT (err u101))
(define-constant ERR_RECORD_NOT_FOUND (err u102))
(define-constant ERR_RECORD_EXISTS (err u103))
(define-constant ERR_INVALID_METADATA (err u104))
(define-constant ERR_PERMISSION_DENIED (err u105))
(define-constant ERR_INVALID_DURATION (err u106))
(define-constant ERR_INVALID_ACCESS_LEVEL (err u107))
(define-constant ERR_INVALID_CATEGORY (err u108))
(define-constant SYSTEM_OWNER tx-sender)

;; Valid Access Levels
(define-constant ACCESS_READ "read")
(define-constant ACCESS_WRITE "write")
(define-constant ACCESS_ADMIN "admin")

;; Data Variables
(define-data-var total-records uint u0)

;; Data Structures
(define-map vault-records
    { record-id: uint }
    {
        title: (string-ascii 50),
        owner: principal,
        content-hash: (string-ascii 64),
        metadata: (string-ascii 200),
        creation-time: uint,
        last-modified: uint,
        category: (string-ascii 20),
        attributes: (list 5 (string-ascii 30))
    }
)

(define-map record-sharing
    { record-id: uint, shared-with: principal }
    {
        access-level: (string-ascii 10),
        granted-at: uint,
        expires-at: uint,
        can-modify: bool
    }
)

;; Private Functions
(define-private (validate-recipient (recipient principal))
    (not (is-eq recipient tx-sender))
)

(define-private (is-record-owner (record-id uint) (user principal))
    (match (map-get? vault-records { record-id: record-id })
        record (is-eq (get owner record) user)
        false
    )
)

(define-private (record-exists (record-id uint))
    (is-some (map-get? vault-records { record-id: record-id }))
)

(define-private (validate-can-modify (can-modify bool))
    (or (is-eq can-modify true) (is-eq can-modify false))
)
