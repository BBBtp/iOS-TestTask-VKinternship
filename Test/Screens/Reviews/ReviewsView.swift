import UIKit

final class ReviewsView: UIView {
    
    let tableView = UITableView()
    let loaderView = LoaderView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLoader()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        loaderView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        loaderView.center = CGPoint(x: bounds.midX + 25, y: bounds.midY)
    }
    
}

// MARK: - Private

private extension ReviewsView {
    
    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
    }
    
    func setupLoader() {
        addSubview(loaderView)
        loaderView.center = center
        loaderView.isHidden = true
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(TotalReviewsCell.self, forCellReuseIdentifier: TotalReviewsCellConfig.reuseId)
    }
    
}

//MARK: - Public

extension ReviewsView {
    
    func showLoader(_ show: Bool) {
        loaderView.isHidden = !show
        show ? loaderView.startAnimation() : loaderView.stopAnimation()
    }
}
