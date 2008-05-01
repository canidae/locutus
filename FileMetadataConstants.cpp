#include "FileMetadataConstants.h"

/* constructors */
FileMetadataConstants::FileMetadataConstants(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
FileMetadataConstants::~FileMetadataConstants() {
}

/* methods */
void FileMetadataConstants::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEMETADATA_CLASS, FILEMETADATA_CLASS_DESCRIPTION);
	album_weight = locutus->settings->loadSetting(setting_class_id, ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = locutus->settings->loadSetting(setting_class_id, ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = locutus->settings->loadSetting(setting_class_id, COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = locutus->settings->loadSetting(setting_class_id, DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = locutus->settings->loadSetting(setting_class_id, DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = locutus->settings->loadSetting(setting_class_id, TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = locutus->settings->loadSetting(setting_class_id, TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);
}
