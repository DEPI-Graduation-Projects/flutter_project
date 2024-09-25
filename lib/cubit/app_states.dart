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

class DeleteChatSuccessState extends AppStates {}

class TempDeleteState extends AppStates {}

class SwapState extends AppStates {}
