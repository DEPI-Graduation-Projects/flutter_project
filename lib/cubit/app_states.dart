abstract class AppStates {}

class AppInitState extends AppStates {}

class ChangeScreenState extends AppStates {}

class PickImageState extends AppStates {}

class ImageLoadingState extends AppStates {}

class UploadChatImageLoadingState extends AppStates {}

class AddMessageSuccessState extends AppStates {}

class AddMessageLoadingState extends AppStates {}

class ChangeSendIconstate extends AppStates {}

class GetChatsSuccessState extends AppStates {}

class GetChatsLoadingState extends AppStates {}

class ChangeUserIdState extends AppStates {}

class CreateChatFailState extends AppStates {}

class CreateChatSuccessState extends AppStates {}

class CreateChatLoadingState extends AppStates {}

class GetChatMessagesLoadingState extends AppStates {}

class GetChatMessagesSuccessState extends AppStates {}

class GetChatMessagesErrorState extends AppStates {}

class DeleteChatSuccessState extends AppStates {}

class TempDeleteState extends AppStates {}

class SwapState extends AppStates {}

class GetUserDataFailedState extends AppStates {}

class GetUserDataLoadingState extends AppStates {}

class GetUserDataSuccessState extends AppStates {}

class DeleteMessageSuccessState extends AppStates {}

class CopyTextSuccessState extends AppStates {}

class SelectMessageSuccesState extends AppStates {}

class DeleteSelectedMessagesState extends AppStates {}

class UpdateChatWallpapperLoadingState extends AppStates {}

class UpdateChatWallpapperSuccessState extends AppStates {
  String chatWallpaperUrl;
  UpdateChatWallpapperSuccessState({required this.chatWallpaperUrl});
}

class UpdateChatWallpapperFailedState extends AppStates {}

class StoryImageLoadingState extends AppStates{}

class PickStoryImageSuccessState extends AppStates{}

class PickStoryImageFailedState extends AppStates{}

class UploadStoryImageLoadingState extends AppStates{}

class UploadStoryImageSuccessState extends AppStates{}

class AddStorySuccessState extends AppStates{}

class AddStoryFailedState extends AppStates{}

class GetStoriesLoadingState extends AppStates{}

class GetStoriesSuccessState extends AppStates{}

class AddStoryLoadingState extends AppStates{}

class UploadStoryImageFailedState extends AppStates{}

class GetStoriesErrorState extends AppStates{
  GetStoriesErrorState(String e);
}
