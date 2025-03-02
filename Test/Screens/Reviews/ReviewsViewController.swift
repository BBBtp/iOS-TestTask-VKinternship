import UIKit

final class ReviewsViewController: UIViewController {
    
    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
    }
    
}

// MARK: - Private

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    func setupViewModel() {
        viewModel.onNewReviewsAdded = { [weak self] indexPaths in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak tableView = self.reviewsView.tableView] in
                guard let tableView = tableView else { return }
                
                if tableView.window != nil {
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                    }
                } else {
                    tableView.reloadData()
                }
            }
        }
        
        viewModel.onReviewExpanded = { [weak self] indexPaths in
            guard let self = self else {return}
            
            DispatchQueue.main.async { [weak tableView = self.reviewsView.tableView] in
                guard let tableView = tableView else {return}
                
                if tableView.window != nil {
                    tableView.performBatchUpdates {
                        tableView.reloadRows(at: indexPaths, with: .none)
                    }
                } else {
                    tableView.reloadData()
                }
            }
        }
    }
}
