import 'dart:math' as math;

class KMeansResult {
  const KMeansResult({
    required this.k,
    required this.silhouette,
    required this.clusters,
  });

  final int k;
  final double silhouette;
  final List<Map<String, dynamic>> clusters;
}

class KMeansService {
  static const int _maxVocabularySize = 120;
  static const int _maxIterations = 100;

  static const Set<String> _stopwords = {
    'yang',
    'dan',
    'di',
    'ke',
    'dari',
    'untuk',
    'pada',
    'dengan',
    'atau',
    'dalam',
    'ini',
    'itu',
    'sebagai',
    'atas',
    'oleh',
    'tentang',
    'hal',
    'surat',
    'permohonan',
    'pemberitahuan',
    'undangan',
    'mohon',
    'kami',
    'kepada',
    'kecamatan',
    'panakkukang',
    'makassar',
    'nomor',
    'tanggal',
    'pelaksanaan',
    'kegiatan',
    'terkait',
    'sehubungan',
    'berdasarkan',
  };

  static const List<String> _prefixes = [
    'meng',
    'meny',
    'men',
    'mem',
    'peng',
    'peny',
    'pen',
    'pem',
    'ber',
    'ter',
    'per',
    'me',
    'pe',
    'se',
    'ke',
  ];

  static const List<String> _suffixes = [
    'annya',
    'kan',
    'nya',
    'an',
    'lah',
    'i',
  ];

  static KMeansResult run(
    List<Map<String, dynamic>> documents, {
    int requestedK = 3,
  }) {
    _validateDocuments(documents);

    final tokenDocuments = documents.map((document) {
      return _tokenize('${document['perihal'] ?? ''}');
    }).toList();

    final documentFrequency = _buildDocumentFrequency(tokenDocuments);

    final terms = _buildVocabulary(documentFrequency);

    if (terms.isEmpty) {
      throw ArgumentError(
        'Perihal surat belum memiliki kata yang dapat dianalisis.',
      );
    }

    final vectors = _buildTfIdfVectors(
      tokenDocuments: tokenDocuments,
      documentFrequency: documentFrequency,
      terms: terms,
    );

    final k = requestedK.clamp(2, documents.length).toInt();

    var centroids = _initializeCentroids(vectors, k);
    var assignments = List<int>.filled(vectors.length, -1);

    for (var iteration = 0; iteration < _maxIterations; iteration++) {
      final nextAssignments = _assignClusters(vectors, centroids);

      final unchanged = _assignmentsAreEqual(assignments, nextAssignments);

      assignments = nextAssignments;

      centroids = _recalculateCentroids(
        vectors: vectors,
        assignments: assignments,
        k: k,
      );

      if (unchanged) {
        break;
      }
    }

    final clusters = _buildClusterResults(
      documents: documents,
      vectors: vectors,
      terms: terms,
      centroids: centroids,
      assignments: assignments,
      k: k,
    );

    final silhouette = _calculateSilhouette(
      vectors: vectors,
      assignments: assignments,
      k: k,
    );

    return KMeansResult(k: k, silhouette: silhouette, clusters: clusters);
  }

  static void _validateDocuments(List<Map<String, dynamic>> documents) {
    if (documents.length < 3) {
      throw ArgumentError(
        'Minimal diperlukan 3 surat masuk untuk proses clustering.',
      );
    }
  }

  static List<String> _tokenize(String text) {
    final cleanedText = text.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9\s]'),
      ' ',
    );

    final result = <String>[];

    for (final rawToken in cleanedText.split(RegExp(r'\s+'))) {
      final token = rawToken.trim();

      if (token.length < 3) {
        continue;
      }

      if (_stopwords.contains(token)) {
        continue;
      }

      final stemmedToken = _stem(token);

      if (stemmedToken.length < 3) {
        continue;
      }

      if (_stopwords.contains(stemmedToken)) {
        continue;
      }

      result.add(stemmedToken);
    }

    return result;
  }

  static String _stem(String token) {
    var value = token;

    for (final prefix in _prefixes) {
      final remainingLength = value.length - prefix.length;

      if (value.startsWith(prefix) && remainingLength >= 4) {
        value = value.substring(prefix.length);
        break;
      }
    }

    for (final suffix in _suffixes) {
      final remainingLength = value.length - suffix.length;

      if (value.endsWith(suffix) && remainingLength >= 4) {
        value = value.substring(0, remainingLength);
        break;
      }
    }

    return value;
  }

  static Map<String, int> _buildDocumentFrequency(
    List<List<String>> tokenDocuments,
  ) {
    final documentFrequency = <String, int>{};

    for (final tokens in tokenDocuments) {
      final uniqueTokens = tokens.toSet();

      for (final token in uniqueTokens) {
        documentFrequency[token] = (documentFrequency[token] ?? 0) + 1;
      }
    }

    return documentFrequency;
  }

  static List<String> _buildVocabulary(Map<String, int> documentFrequency) {
    final vocabulary = documentFrequency.keys.toList();

    vocabulary.sort((first, second) {
      final frequencyComparison = documentFrequency[second]!.compareTo(
        documentFrequency[first]!,
      );

      if (frequencyComparison != 0) {
        return frequencyComparison;
      }

      return first.compareTo(second);
    });

    return vocabulary.take(_maxVocabularySize).toList();
  }

  static List<List<double>> _buildTfIdfVectors({
    required List<List<String>> tokenDocuments,
    required Map<String, int> documentFrequency,
    required List<String> terms,
  }) {
    final termIndex = <String, int>{
      for (var index = 0; index < terms.length; index++) terms[index]: index,
    };

    final documentCount = tokenDocuments.length.toDouble();
    final vectors = <List<double>>[];

    for (final tokens in tokenDocuments) {
      final vector = List<double>.filled(terms.length, 0);
      final termCounts = <String, int>{};

      for (final token in tokens) {
        if (termIndex.containsKey(token)) {
          termCounts[token] = (termCounts[token] ?? 0) + 1;
        }
      }

      final totalTerms = tokens.isEmpty ? 1 : tokens.length;

      for (final entry in termCounts.entries) {
        final term = entry.key;
        final count = entry.value;

        final termFrequency = count / totalTerms;

        final inverseDocumentFrequency =
            math.log(
              (documentCount + 1) / ((documentFrequency[term] ?? 0) + 1),
            ) +
            1;

        final index = termIndex[term];

        if (index != null) {
          vector[index] = termFrequency * inverseDocumentFrequency;
        }
      }

      _normalizeVector(vector);
      vectors.add(vector);
    }

    return vectors;
  }

  static void _normalizeVector(List<double> vector) {
    final squaredSum = vector.fold<double>(
      0,
      (sum, value) => sum + (value * value),
    );

    final norm = math.sqrt(squaredSum);

    if (norm == 0) {
      return;
    }

    for (var index = 0; index < vector.length; index++) {
      vector[index] /= norm;
    }
  }

  static double _distance(List<double> first, List<double> second) {
    if (first.length != second.length) {
      throw ArgumentError('Dimensi kedua vektor harus sama.');
    }

    var squaredSum = 0.0;

    for (var index = 0; index < first.length; index++) {
      final difference = first[index] - second[index];
      squaredSum += difference * difference;
    }

    return math.sqrt(squaredSum);
  }

  static List<List<double>> _initializeCentroids(
    List<List<double>> vectors,
    int k,
  ) {
    final centroids = <List<double>>[List<double>.from(vectors.first)];

    final selectedIndexes = <int>{0};

    while (centroids.length < k) {
      var bestIndex = -1;
      var greatestNearestDistance = -1.0;

      for (var vectorIndex = 0; vectorIndex < vectors.length; vectorIndex++) {
        if (selectedIndexes.contains(vectorIndex)) {
          continue;
        }

        var nearestDistance = double.infinity;

        for (final centroid in centroids) {
          final distance = _distance(vectors[vectorIndex], centroid);

          if (distance < nearestDistance) {
            nearestDistance = distance;
          }
        }

        if (nearestDistance > greatestNearestDistance) {
          greatestNearestDistance = nearestDistance;
          bestIndex = vectorIndex;
        }
      }

      if (bestIndex == -1) {
        break;
      }

      selectedIndexes.add(bestIndex);

      centroids.add(List<double>.from(vectors[bestIndex]));
    }

    return centroids;
  }

  static List<int> _assignClusters(
    List<List<double>> vectors,
    List<List<double>> centroids,
  ) {
    final assignments = <int>[];

    for (final vector in vectors) {
      var bestCluster = 0;
      var bestDistance = double.infinity;

      for (
        var clusterIndex = 0;
        clusterIndex < centroids.length;
        clusterIndex++
      ) {
        final distance = _distance(vector, centroids[clusterIndex]);

        if (distance < bestDistance) {
          bestDistance = distance;
          bestCluster = clusterIndex;
        }
      }

      assignments.add(bestCluster);
    }

    return assignments;
  }

  static bool _assignmentsAreEqual(List<int> previous, List<int> current) {
    if (previous.length != current.length) {
      return false;
    }

    for (var index = 0; index < current.length; index++) {
      if (previous[index] != current[index]) {
        return false;
      }
    }

    return true;
  }

  static List<List<double>> _recalculateCentroids({
    required List<List<double>> vectors,
    required List<int> assignments,
    required int k,
  }) {
    final dimensions = vectors.first.length;

    final sums = List.generate(k, (_) => List<double>.filled(dimensions, 0));

    final counts = List<int>.filled(k, 0);

    for (var vectorIndex = 0; vectorIndex < vectors.length; vectorIndex++) {
      final cluster = assignments[vectorIndex];
      counts[cluster]++;

      for (var dimension = 0; dimension < dimensions; dimension++) {
        sums[cluster][dimension] += vectors[vectorIndex][dimension];
      }
    }

    for (var clusterIndex = 0; clusterIndex < k; clusterIndex++) {
      if (counts[clusterIndex] == 0) {
        final fallbackIndex = clusterIndex % vectors.length;

        sums[clusterIndex] = List<double>.from(vectors[fallbackIndex]);

        continue;
      }

      for (var dimension = 0; dimension < dimensions; dimension++) {
        sums[clusterIndex][dimension] /= counts[clusterIndex];
      }
    }

    return sums;
  }

  static double _calculateSilhouette({
    required List<List<double>> vectors,
    required List<int> assignments,
    required int k,
  }) {
    if (vectors.length < 3 || k < 2) {
      return 0;
    }

    var totalScore = 0.0;

    for (var vectorIndex = 0; vectorIndex < vectors.length; vectorIndex++) {
      final ownCluster = assignments[vectorIndex];

      var ownDistanceSum = 0.0;
      var ownMemberCount = 0;

      final otherDistanceSums = List<double>.filled(k, 0);
      final otherMemberCounts = List<int>.filled(k, 0);

      for (var otherIndex = 0; otherIndex < vectors.length; otherIndex++) {
        if (vectorIndex == otherIndex) {
          continue;
        }

        final distance = _distance(vectors[vectorIndex], vectors[otherIndex]);

        final otherCluster = assignments[otherIndex];

        if (otherCluster == ownCluster) {
          ownDistanceSum += distance;
          ownMemberCount++;
        } else {
          otherDistanceSums[otherCluster] += distance;
          otherMemberCounts[otherCluster]++;
        }
      }

      // Anggota tunggal dalam sebuah klaster memiliki silhouette 0.
      if (ownMemberCount == 0) {
        continue;
      }

      final averageOwnDistance = ownDistanceSum / ownMemberCount;

      var nearestOtherClusterDistance = double.infinity;

      for (var clusterIndex = 0; clusterIndex < k; clusterIndex++) {
        if (clusterIndex == ownCluster) {
          continue;
        }

        if (otherMemberCounts[clusterIndex] == 0) {
          continue;
        }

        final averageDistance =
            otherDistanceSums[clusterIndex] / otherMemberCounts[clusterIndex];

        if (averageDistance < nearestOtherClusterDistance) {
          nearestOtherClusterDistance = averageDistance;
        }
      }

      if (nearestOtherClusterDistance == double.infinity) {
        continue;
      }

      final denominator = math.max(
        averageOwnDistance,
        nearestOtherClusterDistance,
      );

      if (denominator == 0) {
        continue;
      }

      totalScore +=
          (nearestOtherClusterDistance - averageOwnDistance) / denominator;
    }

    return totalScore / vectors.length;
  }

  static List<Map<String, dynamic>> _buildClusterResults({
    required List<Map<String, dynamic>> documents,
    required List<List<double>> vectors,
    required List<String> terms,
    required List<List<double>> centroids,
    required List<int> assignments,
    required int k,
  }) {
    final clusters = <Map<String, dynamic>>[];

    for (var clusterIndex = 0; clusterIndex < k; clusterIndex++) {
      final rankedTermIndexes = List<int>.generate(
        terms.length,
        (index) => index,
      );

      rankedTermIndexes.sort((first, second) {
        return centroids[clusterIndex][second].compareTo(
          centroids[clusterIndex][first],
        );
      });

      final topTerms = rankedTermIndexes
          .where((index) => centroids[clusterIndex][index] > 0)
          .take(3)
          .map((index) => terms[index])
          .toList();

      final label = _createClusterLabel(
        clusterIndex: clusterIndex,
        topTerms: topTerms,
      );

      final members = <Map<String, dynamic>>[];

      for (
        var documentIndex = 0;
        documentIndex < documents.length;
        documentIndex++
      ) {
        if (assignments[documentIndex] != clusterIndex) {
          continue;
        }

        members.add({
          'surat_id': documents[documentIndex]['id'],
          'nomor_surat': documents[documentIndex]['nomor_surat'],
          'perihal': documents[documentIndex]['perihal'],
          'distance': _distance(
            vectors[documentIndex],
            centroids[clusterIndex],
          ),
        });
      }

      members.sort((first, second) {
        final firstDistance =
            (first['distance'] as num?)?.toDouble() ?? double.infinity;

        final secondDistance =
            (second['distance'] as num?)?.toDouble() ?? double.infinity;

        return firstDistance.compareTo(secondDistance);
      });

      clusters.add({
        'cluster_no': clusterIndex + 1,
        'label': label,
        'top_terms': topTerms,
        'jumlah': members.length,
        'members': members,
      });
    }

    return clusters;
  }

  static String _createClusterLabel({
    required int clusterIndex,
    required List<String> topTerms,
  }) {
    if (topTerms.isEmpty) {
      return 'Klaster ${clusterIndex + 1}';
    }

    return topTerms.map(_capitalize).join(' / ');
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
