@testable import FluentKit

extension SchemaBuilder {

	public func field(
		_ field: Column,
		_ dataType: DatabaseSchema.DataType,
		_ constraints: DatabaseSchema.FieldConstraint...
	) -> Self {
		return self.field(.definition(
			name: .key(FieldKey(stringLiteral: field.key)),
			dataType: dataType,
			constraints: constraints
		))
	}

	@discardableResult
	public func unique(on fields: Column..., name: String? = nil) -> Self {
		self.constraint(.constraint(
			.unique(fields: fields.map { .key(FieldKey(stringLiteral: $0.key)) }),
			name: name
		))
	}

	@discardableResult
	public func compositeIdentifier(over fields: Column...) -> Self {
		self.constraint(.constraint(.compositeIdentifier(fields.map { .key(FieldKey(stringLiteral: $0.key)) }), name: ""))
	}

	@discardableResult
	public func deleteUnique(on fields: Column...) -> Self {
		self.schema.deleteConstraints.append(.constraint(
			.unique(fields: fields.map { .key(FieldKey(stringLiteral: $0.key)) })
		))
		return self
	}

	@discardableResult
	public func foreignKey(
		_ field: Column,
		references foreignSchema: String,
		inSpace foreignSpace: String? = nil,
		_ foreignField: Column,
		onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
		onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
		name: String? = nil
	) -> Self {
		self.schema.createConstraints.append(.constraint(
			.foreignKey(
				[.key(FieldKey(stringLiteral: field.key))],
				foreignSchema,
				space: foreignSpace,
				[.key(FieldKey(stringLiteral: foreignField.key))],
				onDelete: onDelete,
				onUpdate: onUpdate
			),
			name: name
		))
		return self
	}

	@discardableResult
	public func foreignKey(
		_ fields: [Column],
		references foreignSchema: String,
		inSpace foreignSpace: String? = nil,
		_ foreignFields: [Column],
		onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
		onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
		name: String? = nil
	) -> Self {
		self.schema.createConstraints.append(.constraint(
			.foreignKey(
				fields.map { .key(FieldKey(stringLiteral: $0.key)) },
				foreignSchema,
				space: foreignSpace,
				foreignFields.map { .key(FieldKey(stringLiteral: $0.key)) },
				onDelete: onDelete,
				onUpdate: onUpdate
			),
			name: name
		))
		return self
	}

	@discardableResult
	public func updateField(
		_ field: Column,
		_ dataType: DatabaseSchema.DataType
	) -> Self {
		self.updateField(.dataType(
			name: .key(FieldKey(stringLiteral: field.key)),
			dataType: dataType
		))
	}
}
