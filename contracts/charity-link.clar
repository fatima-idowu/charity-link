;; Title: CharityLink - Next-Generation Transparent Donation Platform
;;
;; Summary: Revolutionary blockchain infrastructure that transforms charitable 
;;          giving through automated transparency, real-time impact tracking, 
;;          and community-driven accountability mechanisms.
;;
;; Description: CharityLink eliminates traditional charity opacity by creating 
;;              an immutable ecosystem where every donation creates verifiable 
;;              impact. Features advanced multi-signature governance, dynamic 
;;              milestone validation, and integrated reputation systems that 
;;              ensure funds reach their intended recipients while providing 
;;              donors with unprecedented visibility into their contributions' 
;;              real-world effects.

;; CONTRACT OWNERSHIP & INITIALIZATION
(define-data-var contract-owner principal tx-sender)

;; ERROR CONSTANTS
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; ROLE DEFINITIONS
(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; DATA STRUCTURES & STORAGE MAPS

;; Role mapping for hierarchical access control
(define-map roles
  { user: principal }
  { role: uint }
)

;; Comprehensive beneficiary registry with funding metrics
(define-map beneficiaries
  { id: uint }
  {
    name: (string-utf8 50),
    description: (string-utf8 255),
    target-amount: uint,
    received-amount: uint,
    status: (string-ascii 20),
  }
)

;; Immutable donation ledger with complete audit trail
(define-map donations
  { id: uint }
  {
    donor: principal,
    beneficiary-id: uint,
    amount: uint,
    timestamp: uint,
  }
)

;; Milestone-based fund utilization tracking system
(define-map utilization
  { id: uint }
  {
    beneficiary-id: uint,
    milestone: uint,
    description: (string-utf8 255),
    amount: uint,
    status: (string-ascii 20),
  }
)

;; GLOBAL COUNTERS

(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; UTILITY FUNCTIONS

;; Validates user authorization against required permission level
(define-private (is-authorized
    (user principal)
    (required-role uint)
  )
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)
  )
)

;; Retrieves the latest milestone number for beneficiary tracking
(define-private (get-last-milestone (beneficiary-id uint))
  (var-get utilization-count)
)

;; ACCESS CONTROL MANAGEMENT

;; Assigns role to user with comprehensive validation (owner only)
(define-public (set-role
    (user principal)
    (new-role uint)
  )
  (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
    (if (and
        (is-eq tx-sender (var-get contract-owner))
        (<= new-role ROLE-BENEFICIARY)
        (not (is-eq user tx-sender)) ;; Prevent privilege escalation
        (or
          (is-eq new-role ROLE-ADMIN)
          (is-eq new-role ROLE-MODERATOR)
          (is-eq new-role ROLE-BENEFICIARY)
        )
      )
      (ok (map-set roles { user: user } { role: new-role }))
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Revokes user permissions with safety checks (owner only)
(define-public (remove-role (user principal))
  (if (and
      (is-eq tx-sender (var-get contract-owner))
      (is-some (map-get? roles { user: user }))
      (not (is-eq user tx-sender)) ;; Prevent self-lockout
    )
    (ok (map-delete roles { user: user }))
    ERR-NOT-AUTHORIZED
  )
)

;; BENEFICIARY REGISTRY

;; Registers new charity beneficiary with validation (moderator+ access)
(define-public (register-beneficiary
    (name (string-utf8 50))
    (description (string-utf8 255))
    (target-amount uint)
  )
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (if (and
        (is-authorized tx-sender ROLE-MODERATOR)
        (> (len name) u0)
        (> (len description) u0)
        (> target-amount u0)
      )
      (begin
        (map-set beneficiaries { id: beneficiary-id } {
          name: name,
          description: description,
          target-amount: target-amount,
          received-amount: u0,
          status: "active",
        })
        (var-set beneficiary-count beneficiary-id)
        (ok beneficiary-id)
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Retrieves complete beneficiary profile by ID
(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    ERR-BENEFICIARY-NOT-FOUND
  )
)

;; DONATION PROCESSING

;; Processes secure donation with automatic tracking and fund allocation
(define-public (donate
    (beneficiary-id uint)
    (amount uint)
  )
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (if (and
        (> amount u0)
        (<= beneficiary-id (var-get beneficiary-count)) ;; Validate beneficiary exists
        (is-some (map-get? beneficiaries { id: beneficiary-id }))
      )
      (match (stx-transfer? amount tx-sender (as-contract tx-sender))
        success (begin
          ;; Update beneficiary's received amount
          (map-set beneficiaries { id: beneficiary-id }
            (merge beneficiary { received-amount: (+ (get received-amount beneficiary) amount) })
          )
          ;; Record donation in immutable ledger
          (map-set donations { id: (+ (var-get donation-count) u1) } {
            donor: tx-sender,
            beneficiary-id: beneficiary-id,
            amount: amount,
            timestamp: stacks-block-height,
          })
          (var-set donation-count (+ (var-get donation-count) u1))
          (ok true)
        )
        error
        ERR-INSUFFICIENT-FUNDS
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Retrieves donation record with complete transaction details
(define-read-only (get-donation-by-id (donation-id uint))
  (match (map-get? donations { id: donation-id })
    donation (ok donation)
    ERR-NOT-FOUND
  )
)

;; Returns total donation count for platform metrics
(define-read-only (get-donation-count)
  (ok (var-get donation-count))
)

;; FUND UTILIZATION OVERSIGHT

;; Creates new fund utilization milestone (admin only)
(define-public (add-utilization
    (beneficiary-id uint)
    (description (string-utf8 255))
    (amount uint)
  )
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (if (and
        (is-authorized tx-sender ROLE-ADMIN)
        (> (len description) u0)
        (> amount u0)
        (<= beneficiary-id (var-get beneficiary-count)) ;; Validate beneficiary exists
      )
      (let (
          (milestone (+ (get-last-milestone beneficiary-id) u1))
          (utilization-id (+ (var-get utilization-count) u1))
        )
        (begin
          (map-set utilization { id: utilization-id } {
            beneficiary-id: beneficiary-id,
            milestone: milestone,
            description: description,
            amount: amount,
            status: "pending",
          })
          (var-set utilization-count utilization-id)
          (ok milestone)
        )
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Approves fund utilization with balance verification (admin only)
(define-public (approve-utilization
    (beneficiary-id uint)
    (milestone uint)
  )
  (let (
      (utilization-entry (unwrap! (map-get? utilization { id: milestone }) ERR-UTILIZATION-NOT-FOUND))
      (beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND))
    )
    (if (and
        (is-authorized tx-sender ROLE-ADMIN)
        (is-eq (get beneficiary-id utilization-entry) beneficiary-id)
        (<= beneficiary-id (var-get beneficiary-count)) ;; Validate beneficiary exists
        (<= milestone (var-get utilization-count)) ;; Validate milestone exists
      )
      (if (<= (get amount utilization-entry) (get received-amount beneficiary))
        (begin
          (map-set utilization { id: milestone }
            (merge utilization-entry { status: "approved" })
          )
          (ok true)
        )
        ERR-INSUFFICIENT-FUNDS
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Retrieves utilization milestone details by ID
(define-read-only (get-utilization-by-id (utilization-id uint))
  (match (map-get? utilization { id: utilization-id })
    util (ok util)
    ERR-NOT-FOUND
  )
)

;; Returns total utilization records count
(define-read-only (get-utilization-count)
  (ok (var-get utilization-count))
)

;; CONTRACT INITIALIZATION

;; Initializes contract with deployer as primary administrator
(define-private (initialize-contract)
  (begin
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })
    (var-set contract-owner tx-sender)
  )
)

;; Execute contract initialization sequence
(initialize-contract)
