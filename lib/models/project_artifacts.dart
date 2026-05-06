class ProjectArtifacts {
  const ProjectArtifacts({
    this.requirements = '',
    this.useCases = '',
    this.traceability = '',
    this.mockups = '',
    this.srs = '',
  });

  final String requirements;
  final String useCases;
  final String traceability;
  final String mockups;
  final String srs;

  ProjectArtifacts copyWith({
    String? requirements,
    String? useCases,
    String? traceability,
    String? mockups,
    String? srs,
  }) {
    return ProjectArtifacts(
      requirements: requirements ?? this.requirements,
      useCases: useCases ?? this.useCases,
      traceability: traceability ?? this.traceability,
      mockups: mockups ?? this.mockups,
      srs: srs ?? this.srs,
    );
  }
}
