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
    
        viewModel.onNewReviewsAdded = { [weak reviewsView] indexPaths in
            guard let tableView = reviewsView?.tableView else { return }

            DispatchQueue.main.async {
                if tableView.window != nil {
                    tableView.performBatchUpdates {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                    }
                } else {
                    tableView.reloadData() 
                }
            }
        }
    }


}
