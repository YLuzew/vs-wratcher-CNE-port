import funkin.game.scoring.RatingManager;
import funkin.game.scoring.HitWindowData;

function postCreate() {
	var windows = HitWindowData.getWindows(3);
	// 1 = FNF_CNE - 2 = Week7 - 3 = FNF_VSLICE / PE

	ratingManager.ratingData = [];
	ratingManager.initDefaultData(windows);
}