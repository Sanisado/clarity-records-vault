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

(define-private (validate-record-title (title (string-ascii 50)))
    (and
        (> (len title) u0)
        (<= (len title) u50)
    )
)

(define-private (validate-content-hash (hash (string-ascii 64)))
    (and
        (is-eq (len hash) u64)
        (> (len hash) u0)
    )
)

(define-private (validate-attributes (attrs (list 5 (string-ascii 30))))
    (and
        (>= (len attrs) u1)
        (<= (len attrs) u5)
        (is-eq (len (filter validate-attribute attrs)) (len attrs))
    )
)

(define-private (validate-attribute (attr (string-ascii 30)))
    (and
        (> (len attr) u0)
        (<= (len attr) u30)
    )
)

(define-private (validate-metadata (metadata (string-ascii 200)))
    (and
        (>= (len metadata) u1)
        (<= (len metadata) u200)
    )
)

(define-private (validate-category (category (string-ascii 20)))
    (and
        (>= (len category) u1)
        (<= (len category) u20)
    )
)

(define-private (validate-access-level (access-level (string-ascii 10)))
    (or
        (is-eq access-level ACCESS_READ)
        (is-eq access-level ACCESS_WRITE)
        (is-eq access-level ACCESS_ADMIN)
    )
)

(define-private (validate-duration (duration uint))
    (and
        (> duration u0)
        (<= duration u52560) ;; Max duration ~1 year in blocks
    )
)

;; Public Functions
(define-public (create-record 
    (title (string-ascii 50))
    (content-hash (string-ascii 64))
    (metadata (string-ascii 200))
    (category (string-ascii 20))
    (attributes (list 5 (string-ascii 30)))
)
    (let
        (
            (new-id (+ (var-get total-records) u1))
            (current-time block-height)
        )
        (asserts! (validate-record-title title) ERR_INVALID_INPUT)
        (asserts! (validate-content-hash content-hash) ERR_INVALID_INPUT)
        (asserts! (validate-metadata metadata) ERR_INVALID_METADATA)
        (asserts! (validate-category category) ERR_INVALID_CATEGORY)
        (asserts! (validate-attributes attributes) ERR_INVALID_METADATA)

        (map-set vault-records
            { record-id: new-id }
            {
                title: title,
                owner: tx-sender,
                content-hash: content-hash,
                metadata: metadata,
                creation-time: current-time,
                last-modified: current-time,
                category: category,
                attributes: attributes
            }
        )

        (var-set total-records new-id)
        (ok new-id)
    )
)

(define-public (update-record
    (record-id uint)
    (new-title (string-ascii 50))
    (new-content-hash (string-ascii 64))
    (new-metadata (string-ascii 200))
    (new-attributes (list 5 (string-ascii 30)))
)
    (let
        (
            (record (unwrap! (map-get? vault-records { record-id: record-id }) ERR_RECORD_NOT_FOUND))
        )
        (asserts! (is-record-owner record-id tx-sender) ERR_UNAUTHORIZED)
        (asserts! (validate-record-title new-title) ERR_INVALID_INPUT)
        (asserts! (validate-content-hash new-content-hash) ERR_INVALID_INPUT)
        (asserts! (validate-metadata new-metadata) ERR_INVALID_METADATA)
        (asserts! (validate-attributes new-attributes) ERR_INVALID_METADATA)

        (map-set vault-records
            { record-id: record-id }
            (merge record {
                title: new-title,
                content-hash: new-content-hash,
                metadata: new-metadata,
                last-modified: block-height,
                attributes: new-attributes
            })
        )
        (ok true)
    )
)

(define-public (share-record
    (record-id uint)
    (recipient principal)
    (access-level (string-ascii 10))
    (duration uint)
    (can-modify bool)
)
    (let
        (
            (current-time block-height)
            (expiry-time (+ current-time duration))
        )
        (asserts! (record-exists record-id) ERR_RECORD_NOT_FOUND)
        (asserts! (is-record-owner record-id tx-sender) ERR_UNAUTHORIZED)
        (asserts! (validate-recipient recipient) ERR_INVALID_INPUT)
        (asserts! (validate-access-level access-level) ERR_INVALID_ACCESS_LEVEL)
        (asserts! (validate-duration duration) ERR_INVALID_DURATION)
        (asserts! (validate-can-modify can-modify) ERR_INVALID_INPUT)  ;; Add this line

        (map-set record-sharing
            { record-id: record-id, shared-with: recipient }
            {
                access-level: access-level,
                granted-at: current-time,
                expires-at: expiry-time,
                can-modify: can-modify
            }
        )
        (ok true)
    )
)

(define-public (revoke-access
    (record-id uint)
    (user principal)
)
    (begin
        (asserts! (record-exists record-id) ERR_RECORD_NOT_FOUND)
        (asserts! (is-record-owner record-id tx-sender) ERR_UNAUTHORIZED)
        (asserts! (validate-recipient user) ERR_INVALID_INPUT)
        (map-delete record-sharing { record-id: record-id, shared-with: user })
        (ok true)
    )
)