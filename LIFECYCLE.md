### Flow

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant keywords
  participant parse
  participant build
  participant validate
  participant struct

  keywords->>parse: input
  parse->>build: parsed fields
  build->>validate: built struct
  validate->>struct: validated struct
end
```

### `Constructive.new(input)`

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as new(input)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> parse: input
  parse->> build: parsed fields
  build->> validate: built struct
  validate->>struct: validated struct
  struct->> call: returned struct
end
```

### `Constructive.build(input)`

#### Skips

- validating

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as build(input)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> parse: input
  parse->> build: parsed fields
  build->>struct: unvalidated struct
  struct->> call: returned struct
end
```

<!-- ### `Constructive.create(fields)`

#### Skips

- parsing

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as create(fields)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> build: fields
  build->>validate: unvalidated struct
  validate->> struct: validated struct
  struct ->> call: returned struct
end
``` -->

### `Constructive.from_keywords(fields)`

#### Skips

- parsing
- validating

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as build(fields)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> build: fields
  build->>struct: unvalidated struct
  struct->> call: returned struct
end
```

### `Constructive.parse(input)`

#### Skips

- building
- validating

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as parse(input)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> parse: input
  parse->> call: parsed fields
end
```

### `Constructive.validate(struct)`

#### Skips

- parsing
- building

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as validate(struct)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> validate: unvalidated struct
  validate->> call: validated struct
end
```

### `Constructive.replace(struct, fields)`

#### Skips

- parsing
- building
- validating

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as replace(struct, fields)
  participant parse
  participant build
  participant validate
  participant struct

  call ->>  struct: fields
  struct->> call: unvalidated struct
end
```

### `Constructive.update(struct, fields)`

#### Skips

- building

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as update(struct, fields)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> struct: fields
  struct->> validate: unvalidated struct
  validate->> call: validated struct
end
```

### `Constructive.fields(struct)`

#### Skips

- parsing
- building
- validating

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as fields(struct)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> call: struct fields
end
```

### `Constructive.input(struct)`

#### Skips

- parsing
- building
- validating

```mermaid
sequenceDiagram
  rect rgb(255, 255, 255)

  participant call as fields(struct, fields)
  participant parse
  participant build
  participant validate
  participant struct

  call ->> call: input fields
end
```
