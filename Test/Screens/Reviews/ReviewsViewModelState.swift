/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig]()
    var limit = 20
    var offset = 0
    var shouldLoad = true
    var totalReviewsCount: Int = 0
    var totalReviewsItem: (any TableCellConfig)? = nil
    
}
