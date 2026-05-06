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

  Map<String, dynamic> toJson() => {
        'requirements': requirements,
        'useCases': useCases,
        'traceability': traceability,
        'mockups': mockups,
        'srs': srs,
      };

  factory ProjectArtifacts.fromJson(Map<String, dynamic> json) =>
      ProjectArtifacts(
        requirements: json['requirements'] as String? ?? '',
        useCases: json['useCases'] as String? ?? '',
        traceability: json['traceability'] as String? ?? '',
        mockups: json['mockups'] as String? ?? '',
        srs: json['srs'] as String? ?? '',
      );
}
