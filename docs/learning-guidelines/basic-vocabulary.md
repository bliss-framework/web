# Basic vocabulary

Just so you understand what we are trying to say in this manifesto, here is a list of words we use for specific tasks and operations.

### Things
- Syntactic sugar - a piece of code or a way of a programming language that seems like a uniquely implemented feature, but in fact is just a smart way how to reuse already existing functionality to create a new, and, usually, smarter, way to program something.

### Operations
- Ensure - in programming this means "create [given thing], if it doesn't exist already"
    - For example, "Ensure directory" would mean, create it if it doesn't exist already
- Upsert - in database programming this basically means "Ensure", but to be precise, it means "insert row into a table, and if it already exists update it"