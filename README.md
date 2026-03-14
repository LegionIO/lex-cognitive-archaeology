# lex-cognitive-archaeology

Cognitive archaeology metaphor for recovering deeply buried cognitive artifacts — excavation sites, depth-weighted artifact discovery, and restoration.

## What It Does

Models the retrieval of deeply buried cognitive content as archaeological excavation. Sites have five depth levels (surface to bedrock), and digging at different depths surfaces different artifact types according to weighted probability tables. Surface digs find common patterns and knowledge; bedrock digs surface rare schemas and procedures. Artifacts degrade with depth — ancient finds need restoration.

## Core Concept: Depth and Rarity

```
surface  -> common types (pattern, knowledge)     -> high preservation
shallow  -> mixed types                            -> good preservation
mid      -> deeper history                         -> moderate preservation
deep     -> ancient history                        -> degraded
bedrock  -> primordial (schema, procedure, belief) -> ruins
```

## Usage

```ruby
client = Legion::Extensions::CognitiveArchaeology::Client.new

# Open an excavation site
site = client.create_site(name: :infrastructure_knowledge_base, domain: :infrastructure)

# Dig at a specific depth
artifact = client.dig(site_id: site[:site][:id], depth_level: :surface)
# => { artifact: { type: :pattern, preservation: 0.91, integrity: 0.88, epoch: :recent, ... } }

# Dig deeper for rarer artifacts
deep_find = client.dig(site_id: site[:site][:id], depth_level: :bedrock)
# => { artifact: { type: :schema, preservation: 0.23, integrity: 0.31, epoch: :ancient, ... } }

# Restore a damaged artifact
client.restore_artifact(artifact_id: deep_find[:artifact][:id])
# => { artifact: { preservation: 0.45, integrity: 0.52, ... } }

# Full excavation sweep across all depth levels
client.excavate(site_id: site[:site][:id])
# => { artifacts: [...all found artifacts across all depths...] }

# Check overall dig status
client.archaeology_status
# => { site_count: 1, artifact_count: 6, depth_distribution: {...}, avg_preservation: 0.61 }
```

## Integration

Pairs with lex-memory (artifact types map to memory trace types: `:memory_fragment` -> episodic, `:schema` -> semantic). Pairs with lex-cognitive-apprenticeship (a recovered `:procedure` artifact can seed a new apprenticeship). Pairs with lex-dream (dream association walks can trigger archaeology to surface related ancient associations).

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
