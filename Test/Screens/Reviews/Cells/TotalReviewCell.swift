import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct TotalReviewsCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: TotalReviewsCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст с количеством отзывов.
    let totalReviewsText: NSAttributedString
    
    /// Объект, хранящий посчитанные фреймы для ячейки.
    fileprivate let layout = TotalReviewsCellLayout()
    
}

// MARK: - TableCellConfig

extension TotalReviewsCellConfig: TableCellConfig {
    
    /// Метод обновления ячейки.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? TotalReviewsCell else { return }
        cell.totalReviewsLabel.attributedText = totalReviewsText
        cell.config = self
    }
    
    /// Метод, возвращающий высоту ячейки.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
    
}

// MARK: - Cell

final class TotalReviewsCell: UITableViewCell {
    
    fileprivate var config: Config?
    
    fileprivate let totalReviewsLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        totalReviewsLabel.frame = layout.totalReviewsLabelFrame
    }
    
}

// MARK: - Private

private extension TotalReviewsCell {
    
    func setupCell() {
        contentView.addSubview(totalReviewsLabel)
        totalReviewsLabel.textAlignment = .center
        totalReviewsLabel.numberOfLines = 0
    }
    
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class TotalReviewsCellLayout {
    
    // MARK: - Фреймы
    
    private(set) var totalReviewsLabelFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    /// Отступ сверху от ячейки отзыва
    private let totalToReview = 10.0
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: TotalReviewsCellConfig, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        let maxY = insets.top + totalToReview
        
        let textSize = config.totalReviewsText.boundingRect(width: width).size
        let centerX = (maxWidth - textSize.width) / 2
        
        totalReviewsLabelFrame = CGRect(
            origin: CGPoint(x: centerX, y: maxY),
            size: textSize
        )
        
        return totalReviewsLabelFrame.maxY + insets.bottom
    }
    
}

// MARK: - Typealias

fileprivate typealias Config = TotalReviewsCellConfig
fileprivate typealias Layout = TotalReviewsCellLayout
