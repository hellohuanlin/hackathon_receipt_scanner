
fileprivate let image_compression_quality: CGFloat = 1

enum ReceiptScanner {
  static func scanAndDetectMoney(navVC: UINavigationController) async -> (UIImage, [TextRecognitionResult])? {
    
    let image: UIImage? = await DocumentScanUtil.scan(navVC: navVC, compressionQuality: image_compression_quality)
    guard let image else { return nil }
    
    let results = await TextRecognitionUtil.recognizeText(image: image)
    let filtered = results.filter(\.isMoney)
    let visualizedImage = TextRecognitionUtil.visualize(image: image, results: filtered.map { $0 })
    return (visualizedImage, filtered)
  }
}

extension TextRecognitionResult {
  var isMoney: Bool {
    return moneyAmount != nil
  }
  
  var moneyAmount: Decimal? {
    // Examples
    // "USD$ 12.34"
    // "$12.34"
    // "12.34"
    // "500 King Dr"
    
    let containsDigit = text.anySatisfy(\.isNumber)
    guard containsDigit else { return nil }
    
    let nonNumbers = CharacterSet.letters
      .union(.whitespacesAndNewlines)
      .union(.init(charactersIn: "$€£¥"))
    return Decimal(string: text.trimmingCharacters(in: nonNumbers))
  }
}
