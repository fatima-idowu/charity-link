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