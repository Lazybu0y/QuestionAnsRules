-- Version Management
questionnaire_versions (
  id UUID PRIMARY KEY,
  questionnaire_id VARCHAR(100),
  version VARCHAR(20),
  status ENUM('draft', 'active', 'deprecated'),
  created_at TIMESTAMP,
  metadata JSONB
)

-- Questions
questions (
  id UUID PRIMARY KEY,
  version_id UUID REFERENCES questionnaire_versions(id),
  question_key VARCHAR(100),
  question_type ENUM('single-choice', 'multiple-choice', 'text', 'number'),
  question_text TEXT,
  level INTEGER,
  parent_question_id UUID REFERENCES questions(id),
  sort_order INTEGER,
  config JSONB,
  created_at TIMESTAMP,
  INDEX(version_id, level, sort_order),
  INDEX(question_key, version_id)
)

-- Answer Sets
answer_sets (
  id UUID PRIMARY KEY,
  version_id UUID REFERENCES questionnaire_versions(id),
  set_key VARCHAR(100),
  answer_type ENUM('static', 'api', 'computed'),
  config JSONB, -- API endpoints, static options, computation rules
  cache_ttl INTEGER,
  INDEX(version_id, set_key)
)

-- Question-Answer Relationships
question_answers (
  question_id UUID REFERENCES questions(id),
  answer_set_id UUID REFERENCES answer_sets(id),
  PRIMARY KEY(question_id, answer_set_id)
)

-- Navigation Rules
navigation_rules (
  id UUID PRIMARY KEY,
  version_id UUID REFERENCES questionnaire_versions(id),
  from_question_id UUID REFERENCES questions(id),
  rule_name VARCHAR(100),
  condition TEXT, -- JavaScript expression
  priority INTEGER,
  target_question_id UUID REFERENCES questions(id),
  target_type ENUM('question', 'evaluation', 'end'),
  created_at TIMESTAMP,
  INDEX(from_question_id, priority),
  INDEX(version_id, from_question_id)
)

-- Final Evaluation Rules
evaluation_rules (
  id UUID PRIMARY KEY,
  version_id UUID REFERENCES questionnaire_versions(id),
  rule_name VARCHAR(100),
  condition TEXT,
  step_id VARCHAR(100),
  priority INTEGER,
  metadata JSONB,
  INDEX(version_id, priority)
)

-- Rule Dependencies (for optimization)
rule_dependencies (
  rule_id UUID,
  depends_on_question VARCHAR(100),
  dependency_type ENUM('direct', 'indirect'),
  INDEX(rule_id, depends_on_question)
)

-- Active Configurations (for quick lookups)
active_configurations (
  questionnaire_id VARCHAR(100) PRIMARY KEY,
  active_version_id UUID REFERENCES questionnaire_versions(id),
  fallback_version_id UUID REFERENCES questionnaire_versions(id),
  updated_at TIMESTAMP
)