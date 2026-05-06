class ProjectArtifacts {
  const ProjectArtifacts({
    this.requirements = '',
    this.useCases = '',
    this.traceability = '',
    this.srs = '',
  });

  final String requirements;
  final String useCases;
  final String traceability;
  final String srs;

  ProjectArtifacts copyWith({
    String? requirements,
    String? useCases,
    String? traceability,
    String? srs,
  }) {
    return ProjectArtifacts(
      requirements: requirements ?? this.requirements,
      useCases: useCases ?? this.useCases,
      traceability: traceability ?? this.traceability,
      srs: srs ?? this.srs,
    );
  }
}
