;; YieldPuzzle - Financial Literacy Game with DeFi Yield
;; A game where players solve financial puzzles to unlock yield opportunities

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-solved (err u101))
(define-constant err-wrong-answer (err u102))
(define-constant err-insufficient-stake (err u103))
(define-constant err-no-yield (err u104))
(define-constant err-puzzle-not-found (err u105))

;; Minimum stake required to play (in microSTX)
(define-constant min-stake u1000000) ;; 1 STX

;; Data Variables
(define-data-var total-puzzles uint u0)
(define-data-var yield-pool uint u0)

;; Data Maps
(define-map puzzles
  { puzzle-id: uint }
  {
    question: (string-ascii 256),
    answer-hash: (buff 32),
    reward-percentage: uint,
    difficulty: uint,
    active: bool
  }
)

(define-map player-progress
  { player: principal }
  {
    puzzles-solved: uint,
    total-staked: uint,
    total-earned: uint,
    last-solved: uint
  }
)

(define-map puzzle-solutions
  { player: principal, puzzle-id: uint }
  { solved: bool, earned: uint }
)

;; Read-only functions

(define-read-only (get-puzzle (puzzle-id uint))
  (map-get? puzzles { puzzle-id: puzzle-id })
)

(define-read-only (get-player-progress (player principal))
  (default-to
    { puzzles-solved: u0, total-staked: u0, total-earned: u0, last-solved: u0 }
    (map-get? player-progress { player: player })
  )
)

(define-read-only (is-puzzle-solved (player principal) (puzzle-id uint))
  (default-to
    false
    (get solved (map-get? puzzle-solutions { player: player, puzzle-id: puzzle-id }))
  )
)

(define-read-only (get-yield-pool)
  (ok (var-get yield-pool))
)

(define-read-only (get-total-puzzles)
  (ok (var-get total-puzzles))
)

;; Private functions

(define-private (hash-answer (answer (string-ascii 64)))
  (sha256 (unwrap-panic (to-consensus-buff? answer)))
)

;; Public functions

;; Create a new puzzle (owner only)
(define-public (create-puzzle 
  (question (string-ascii 256))
  (answer (string-ascii 64))
  (reward-percentage uint)
  (difficulty uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((puzzle-id (+ (var-get total-puzzles) u1)))
      (map-set puzzles
        { puzzle-id: puzzle-id }
        {
          question: question,
          answer-hash: (hash-answer answer),
          reward-percentage: reward-percentage,
          difficulty: difficulty,
          active: true
        }
      )
      (var-set total-puzzles puzzle-id)
      (ok puzzle-id)
    )
  )
)

;; Stake STX to play the game
(define-public (stake-to-play (amount uint))
  (begin
    (asserts! (>= amount min-stake) err-insufficient-stake)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((current-progress (get-player-progress tx-sender)))
      (map-set player-progress
        { player: tx-sender }
        {
          puzzles-solved: (get puzzles-solved current-progress),
          total-staked: (+ (get total-staked current-progress) amount),
          total-earned: (get total-earned current-progress),
          last-solved: (get last-solved current-progress)
        }
      )
      ;; Add to yield pool
      (var-set yield-pool (+ (var-get yield-pool) amount))
      (ok true)
    )
  )
)

;; Solve a puzzle and earn yield
(define-public (solve-puzzle (puzzle-id uint) (answer (string-ascii 64)))
  (let (
    (puzzle (unwrap! (get-puzzle puzzle-id) err-puzzle-not-found))
    (current-progress (get-player-progress tx-sender))
  )
    (asserts! (get active puzzle) err-puzzle-not-found)
    (asserts! (not (is-puzzle-solved tx-sender puzzle-id)) err-already-solved)
    (asserts! (> (get total-staked current-progress) u0) err-insufficient-stake)
    (asserts! (is-eq (get answer-hash puzzle) (hash-answer answer)) err-wrong-answer)
    
    ;; Calculate reward based on stake and puzzle difficulty
    (let (
      (reward (/ (* (get total-staked current-progress) (get reward-percentage puzzle)) u100))
      (available-yield (var-get yield-pool))
    )
      (asserts! (> available-yield u0) err-no-yield)
      (let ((actual-reward (if (> reward available-yield) available-yield reward)))
        ;; Transfer reward
        (try! (as-contract (stx-transfer? actual-reward tx-sender (unwrap-panic (some tx-sender)))))
        
        ;; Update player progress
        (map-set player-progress
          { player: tx-sender }
          {
            puzzles-solved: (+ (get puzzles-solved current-progress) u1),
            total-staked: (get total-staked current-progress),
            total-earned: (+ (get total-earned current-progress) actual-reward),
            last-solved: puzzle-id
          }
        )
        
        ;; Mark puzzle as solved
        (map-set puzzle-solutions
          { player: tx-sender, puzzle-id: puzzle-id }
          { solved: true, earned: actual-reward }
        )
        
        ;; Update yield pool
        (var-set yield-pool (- available-yield actual-reward))
        (ok actual-reward)
      )
    )
  )
)

;; Withdraw remaining stake (owner only, for emergency)
(define-public (emergency-withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (as-contract (stx-transfer? amount tx-sender contract-owner))
  )
)

;; Deactivate a puzzle (owner only)
(define-public (deactivate-puzzle (puzzle-id uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((puzzle (unwrap! (get-puzzle puzzle-id) err-puzzle-not-found)))
      (map-set puzzles
        { puzzle-id: puzzle-id }
        (merge puzzle { active: false })
      )
      (ok true)
    )
  )
)

;; Initialize contract with sample puzzles
(begin
  ;; Sample puzzles will be added by contract owner after deployment
  (print "YieldPuzzle contract initialized")
)