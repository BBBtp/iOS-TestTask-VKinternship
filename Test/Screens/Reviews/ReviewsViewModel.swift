import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
    
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    /// Зымыкание  для обновления `UITableView`
    var onNewReviewsAdded: (([IndexPath]) -> Void)?
    /// Замыкание для открытия полного текста отзыва
    var onReviewExpanded: (([IndexPath]) -> Void)?
    /// Замыкание для состояния загрузки
    var onLoading: ((Bool) -> Void)?
    /// Флаг для показа лоадера
    var shouldShowLoader: Bool {
        return !hasLoadedOnce
    }
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    private var hasLoadedOnce = false
    
    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }
    
    deinit {
        onStateChange = nil
        onNewReviewsAdded = nil
        onReviewExpanded = nil
    }
    
}

// MARK: - Internal

extension ReviewsViewModel {
    
    typealias State = ReviewsViewModelState
    
    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = true
        onLoading?(state.shouldLoad)
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {return}
            self.reviewsProvider
                .getReviews(offset: self.state.offset) {result in
                    
                    DispatchQueue.main.async {
                        self.state.shouldLoad = false
                        self.onLoading?(self.state.shouldLoad)
                    }
                    self.gotReviews(result)
                    
                    if !self.hasLoadedOnce {
                        self.hasLoadedOnce = true
                        DispatchQueue.main.async {
                            self.onLoading?(false)
                        }
                    }
                }
        }
    }
    
    /// Метод для pull-to-refresh
    func refreshReviews(completion: @escaping () -> Void) {
        guard state.shouldLoad else { return }
        state.shouldLoad = true
        state.offset = 0
        state.items.removeAll()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {return}
            self.reviewsProvider
                .getReviews(offset: self.state.offset) {result in
                    
                    DispatchQueue.main.async {
                        self.state.shouldLoad = false
                    }
                    self.gotReviews(result)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
        }
    }
    
}

// MARK: - Private

private extension ReviewsViewModel {
    
    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            
            DispatchQueue.global().async { [weak self] in
                guard let self = self else {return}
                do {
                    let reviews = try self.decoder.decode(
                        Reviews.self,
                        from: data
                    )
                    let newItems = reviews.items.map(self.makeReviewItem)
                    let startIndex = self.state.items.count
                    let endIndex = startIndex + newItems.count
                    let indexPaths = (startIndex..<endIndex).map {
                        IndexPath(row: $0, section: 0)
                    }
                    
                    guard !newItems.isEmpty else { return }
                    
                    DispatchQueue.main.async {
                        self.state.items += newItems
                        self.state.offset += self.state.limit
                        self.state.totalReviewsCount = reviews.count
                        self.state.totalReviewsItem = self.makeTotalReviewItem()
                        self.state.shouldLoad = self.state.offset < reviews.count
                        self.onNewReviewsAdded?(indexPaths)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.state.shouldLoad = true
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.state.shouldLoad = true
            }
        }
    }
    
    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(
                where: { ($0 as? ReviewItem)?.id == id
                }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async {
            self.onReviewExpanded?([indexPath])
        }
    }
    
}

// MARK: - Items

private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    typealias TotalReviewsItem = TotalReviewsCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let username = [review.firstName, review.lastName].joined(separator: " ").attributed(
            font: .username
        )
        let rating = ratingRenderer.ratingImage(review.rating)
        
        let photos = [
            UIImage(named: "IMG_0001"),
            UIImage(named: "IMG_0002"),
            UIImage(named: "IMG_0003"),
            UIImage(named: "IMG_0004"),
            UIImage(named: "IMG_0005"),
        ].compactMap {$0}
        
        let randomPhotoCount = Int.random(in: 0..<photos.count)
        let selectPhotos = Array(photos.prefix(randomPhotoCount))
        
        let item = ReviewItem(
            reviewText: reviewText,
            created: created,
            onTapShowMore: showMoreReview,
            avatarImage: UIImage(named: "avatarImage"),
            username: username,
            rating: rating,
            photos: selectPhotos
        )
        return item
    }
    
    func makeTotalReviewItem() -> TotalReviewsItem {
        let totalReviewsText = "\(state.totalReviewsCount) отзывов".attributed(
            font: .created,
            color: .created
        )
        let item = TotalReviewsItem(
            totalReviewsText: totalReviewsText
        )
        return item
    }
    
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < state.items.count {
            let config = state.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: config.reuseId,
                for: indexPath
            )
            config.update(cell: cell)
            return cell
        } else {
            guard let config = state.totalReviewsItem else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(
                withIdentifier: config.reuseId,
                for: indexPath
            )
            config.update(cell: cell)
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < state.items.count{
            return state
                .items[indexPath.row]
                .height(with: tableView.bounds.size)
        } else {
            guard let totalReviewsItem = state.totalReviewsItem else {
                return 0
            }
            return totalReviewsItem.height(with: tableView.bounds.size)
        }
        
    }
    
    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(
            scrollView: scrollView,
            targetOffsetY: targetContentOffset.pointee.y
        ) {
            getReviews()
        }
    }
    
    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
    
}
