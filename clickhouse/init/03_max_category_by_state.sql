SELECT
    us_state,
    argMax(cat_id, amount) AS max_cat_id_by_amount,
    max(amount) AS max_transaction_amount
FROM transactions_raw
GROUP BY us_state
ORDER BY us_state
