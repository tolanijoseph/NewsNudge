;; NewsNudge - Tipping Service for Independent Journalists
;; A simple, secure tipping platform on Stacks blockchain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-journalist (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-not-authorized (err u103))
(define-constant err-transfer-failed (err u104))
(define-constant err-journalist-not-found (err u105))

;; Minimum tip amount (0.1 STX)
(define-constant min-tip-amount u100000)

;; Data Variables
(define-data-var platform-fee-percentage uint u5) ;; 5% platform fee

;; Data Maps
(define-map journalists
  principal
  {
    name: (string-ascii 50),
    bio: (string-utf8 200),
    total-tips-received: uint,
    tip-count: uint,
    registered-at: uint
  }
)

(define-map tips
  uint
  {
    from: principal,
    to: principal,
    amount: uint,
    message: (string-utf8 140),
    timestamp: uint
  }
)

(define-data-var tip-nonce uint u0)

;; Read-only functions

(define-read-only (get-journalist (journalist principal))
  (map-get? journalists journalist)
)

(define-read-only (get-tip (tip-id uint))
  (map-get? tips tip-id)
)

(define-read-only (get-platform-fee-percentage)
  (var-get platform-fee-percentage)
)

(define-read-only (is-journalist (user principal))
  (is-some (map-get? journalists user))
)

(define-read-only (calculate-fee (amount uint))
  (/ (* amount (var-get platform-fee-percentage)) u100)
)

(define-read-only (get-tip-count)
  (var-get tip-nonce)
)

;; Public functions

;; Register as a journalist
(define-public (register-journalist (name (string-ascii 50)) (bio (string-utf8 200)))
  (let
    (
      (caller tx-sender)
    )
    ;; Check if already registered
    (asserts! (is-none (map-get? journalists caller)) err-already-registered)
    
    ;; Register journalist
    (ok (map-set journalists caller {
      name: name,
      bio: bio,
      total-tips-received: u0,
      tip-count: u0,
      registered-at: stacks-block-height
    }))
  )
)

;; Update journalist profile
(define-public (update-profile (name (string-ascii 50)) (bio (string-utf8 200)))
  (let
    (
      (caller tx-sender)
      (journalist-data (unwrap! (map-get? journalists caller) err-not-journalist))
    )
    (ok (map-set journalists caller (merge journalist-data {
      name: name,
      bio: bio
    })))
  )
)

;; Send a tip to a journalist
(define-public (send-tip (journalist principal) (amount uint) (message (string-utf8 140)))
  (let
    (
      (caller tx-sender)
      (journalist-data (unwrap! (map-get? journalists journalist) err-journalist-not-found))
      (fee (calculate-fee amount))
      (net-amount (- amount fee))
      (current-nonce (var-get tip-nonce))
    )
    ;; Validate amount
    (asserts! (>= amount min-tip-amount) err-invalid-amount)
    
    ;; Transfer STX to journalist (net amount after fee)
    (try! (stx-transfer? net-amount caller journalist))
    
    ;; Transfer fee to contract owner
    (if (> fee u0)
      (try! (stx-transfer? fee caller contract-owner))
      true
    )
    
    ;; Update journalist stats
    (map-set journalists journalist (merge journalist-data {
      total-tips-received: (+ (get total-tips-received journalist-data) net-amount),
      tip-count: (+ (get tip-count journalist-data) u1)
    }))
    
    ;; Record tip
    (map-set tips current-nonce {
      from: caller,
      to: journalist,
      amount: amount,
      message: message,
      timestamp: stacks-block-height
    })
    
    ;; Increment nonce
    (var-set tip-nonce (+ current-nonce u1))
    
    (ok current-nonce)
  )
)

;; Admin function to update platform fee (only contract owner)
(define-public (set-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    (asserts! (<= new-fee u20) err-invalid-amount) ;; Max 20% fee
    (ok (var-set platform-fee-percentage new-fee))
  )
)