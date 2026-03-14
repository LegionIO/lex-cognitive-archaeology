# lex-cognitive-archaeology

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Cognitive archaeology metaphor for recovering deeply buried cognitive artifacts — excavation sites have depth levels (surface to bedrock), and digging surfaces artifacts with type probabilities weighted by depth and epoch.

## Gem Info

- **Gem name**: `lex-cognitive-archaeology`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::CognitiveArchaeology`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_archaeology/
  cognitive_archaeology.rb       # Main extension module
  version.rb                     # VERSION = '0.1.0'
  client.rb                      # Client wrapper
  helpers/
    constants.rb                 # Artifact types, depth levels, epoch names, rarity weights, labels
    artifact.rb                  # Artifact value object (type, depth, preservation, integrity, epoch)
    site.rb                      # Site value object (domain, depth levels, artifacts collected)
    archaeology_engine.rb        # ArchaeologyEngine — manages sites, excavation, restoration
  runners/
    cognitive_archaeology.rb     # Runner module (extend self) with 7 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
ARTIFACT_TYPES = %i[pattern skill knowledge memory_fragment association procedure belief schema]
DOMAIN_TYPES   = %i[general infrastructure reasoning memory identity emotional procedural]
EXCAVATION_DEPTH_LEVELS = %i[surface shallow mid deep bedrock]
EPOCH_NAMES = %i[recent near_past medium_past distant_past ancient]

# Weighted probability tables: deeper levels surface rarer types
DEPTH_RARITY_WEIGHTS = {
  surface:  { pattern: 30, skill: 20, knowledge: 25, memory_fragment: 15, association: 10, ... },
  bedrock:  { schema: 30, procedure: 25, belief: 20, memory_fragment: 15, association: 10, ... }
  # ... (each depth has its own probability distribution)
}

PRESERVATION_LABELS = {
  (0.8..) => :pristine, (0.6...0.8) => :intact, (0.4...0.6) => :damaged,
  (0.2...0.4) => :fragmented, (..0.2) => :ruins
}
INTEGRITY_LABELS = {
  (0.85..) => :complete, (0.65...0.85) => :mostly_complete, (0.45...0.65) => :partial,
  (0.25...0.45) => :fragmentary, (..0.25) => :trace_only
}
DENSITY_LABELS = { (0.7..) => :rich, (0.4...0.7) => :moderate, (..0.4) => :sparse }
DEPTH_LABELS   = {
  surface: :contemporary, shallow: :recent_history, mid: :historical,
  deep: :ancient_history, bedrock: :primordial
}
```

## Runners

### `Runners::CognitiveArchaeology`

Uses `extend self` — methods are module-level, not instance-delegating. Delegates to a per-call `engine` (parameter-injected `Helpers::ArchaeologyEngine` instance via `engine:` keyword, defaulting to a shared `@engine ||=`).

- `create_site(name:, domain:, engine: @engine)` — register an excavation site with a domain; initializes depth tracking at `:surface`
- `dig(site_id:, depth_level:, engine: @engine)` — excavate at a specific depth; surfaces artifacts with type probabilities drawn from `DEPTH_RARITY_WEIGHTS[depth_level]`; returns artifact or `:empty` if nothing found
- `excavate(site_id:, engine: @engine)` — full excavation sweep across all depth levels; returns array of all found artifacts
- `restore_artifact(artifact_id:, engine: @engine)` — increase preservation and integrity of a damaged artifact; returns restoration result hash
- `list_artifacts(engine: @engine)` — all artifacts across all sites as array of hashes
- `archaeology_status(engine: @engine)` — summary: site count, artifact count, depth distribution, average preservation

## Helpers

### `Helpers::ArchaeologyEngine`
Core engine managing `@sites` and `@artifacts` hashes. `dig_at_depth` performs weighted random draw from `DEPTH_RARITY_WEIGHTS[depth_level]` to determine artifact type, then generates artifact with preservation and integrity values that decrease with depth (surface artifacts are better preserved). `excavate_site` calls `dig_at_depth` for each depth level. `restore` increases preservation and integrity values, clamped to 1.0.

### `Helpers::Artifact`
Value object: type, depth_level, preservation (0.0–1.0), integrity (0.0–1.0), epoch (one of `EPOCH_NAMES`), site_id, domain. `preservation_label` and `integrity_label` map values to human-readable labels. `recoverable?` returns true when preservation > 0.2 (ruins are not recoverable).

### `Helpers::Site`
Value object: name, domain, depths_excavated array, artifact_ids array. `excavated_at?(depth_level)` checks whether a depth has been visited. `add_artifact!` records an artifact ID.

## Integration Points

No actor defined. This extension models recovery of deeply buried cognitive content — ancient patterns, procedures, and schemas that are hard to access but high-value. Pairs with lex-memory (archaeology surfaces artifacts that map to memory traces by type: `:memory_fragment` artifacts correlate to `episodic` traces, `:schema` artifacts to `semantic` traces). Pairs with lex-cognitive-apprenticeship (archaeological recovery of a `:procedure` artifact can seed a new apprenticeship). Pairs with lex-dream (dream association walks can trigger archaeology to surface related ancient associations).

## Development Notes

- `extend self` pattern: runner is a module with module-level methods; shared `@engine` lives in the module's singleton
- `DEPTH_RARITY_WEIGHTS` is the core mechanic: each depth level has its own weighted probability table; deeper levels have higher weights for rare types (`:schema`, `:procedure`) and lower weights for common types (`:pattern`, `:knowledge`)
- `dig` at `:surface` is more likely to surface `:pattern` and `:knowledge`; `dig` at `:bedrock` is more likely to surface `:schema` and `:procedure`
- Preservation values decrease with depth: surface artifacts start at high preservation; bedrock artifacts start degraded
- `restore_artifact` is the repair pathway — callers must actively restore damaged/fragmented artifacts before using them
- Epoch names (`:recent` to `:ancient`) are assigned based on depth level, providing temporal context for recovered artifacts
