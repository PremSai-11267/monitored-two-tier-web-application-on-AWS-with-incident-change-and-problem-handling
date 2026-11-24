
-- Project 1: Life Sciences Sample Tracker
-- Target database: prem_intern_p1

CREATE TABLE IF NOT EXISTS public.samples (
    sample_id VARCHAR(50) PRIMARY KEY,
    experiment VARCHAR(150) NOT NULL,
    sample_type VARCHAR(20) NOT NULL
        CHECK (sample_type IN ('RNA', 'DNA', 'Protein', 'Other')),
    researcher VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('Pending', 'In Progress', 'Completed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
