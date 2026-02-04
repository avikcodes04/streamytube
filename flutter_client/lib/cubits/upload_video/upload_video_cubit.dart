import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_client/services/upload_video_service.dart';
import 'package:path/path.dart' show dirname;

import 'package:path_provider/path_provider.dart';
part 'upload_video_state.dart';

class UploadVideoCubit extends Cubit<UploadVideoState> {
  UploadVideoCubit() : super(UploadVideoInitial());
  final UploadVideoService uploadVideoService = UploadVideoService();

  Future<void> uploadVideo({
    required File videoFile,
    required File thumbnailFile,
    required String title,
    required String description,
    required String visibility,
  }) async {
    try {
      emit(UploadVideoLoading());
      final videoData = await uploadVideoService.getPresignedUrlForVideo();
      final videoId = videoData['video_id'];

      print(videoData);
      final thumbnailData = await uploadVideoService
          .getPresignedUrlForThumbnail(videoId);
      final appDir = await getApplicationDocumentsDirectory();

      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }

      final newThumbnailPath =
          "${appDir.path}/${thumbnailData['thumbnail_id']}";
      final newVideoPath = "${appDir.path}/${videoData['video_id']}";

      final thumbnailDir = Directory(dirname(newThumbnailPath));
      final videoDir = Directory(dirname(newVideoPath));

      if (!thumbnailDir.existsSync()) {
        thumbnailDir.createSync(recursive: true);
      }

      if (!videoDir.existsSync()) {
        videoDir.createSync(recursive: true);
      }

      File newThumbnailFile = await thumbnailFile.copy(newThumbnailPath);
      File newVideoFile = await videoFile.copy(newVideoPath);
      // //RENAME THE THUMBNAIL AND VIDEO FILES
      // thumbnailFile = await thumbnailFile.copy(
      //   "${appDir.path}/${thumbnailData['thumbnail_id']}",
      // );

      // videoFile = await videoFile.copy(
      //   "${appDir.path}/${videoData['video_id']}",
      // );

      final isThumbnailUploaded = await uploadVideoService.uploadFileToS3(
        presignedUrl: thumbnailData['url'],
        file: newThumbnailFile,
        isVideo: false,
      );
      final isVideoUploaded = await uploadVideoService.uploadFileToS3(
        presignedUrl: videoData['url'],
        file: newVideoFile,
        isVideo: true,
      );

      // if (isThumbnailUploaded && isVideoUploaded) {
      //   final isMetadataUploaded = await uploadVideoService.uploadMetadata(
      //     title: title,
      //     description: description,
      //     visibility: visibility,
      //     s3key: videoData['video_id'],
      //   );
      //   if (isMetadataUploaded) {
      //     emit(UploadVideoSuccess());
      //   } else {
      //     emit(const UploadVideoError("Failed to upload metadata"));
      //   }
      // }

      if (!isThumbnailUploaded) {
        emit(const UploadVideoError("Thumbnail upload failed"));
        return;
      }

      if (!isVideoUploaded) {
        emit(const UploadVideoError("Video upload failed"));
        return;
      }

      final isMetadataUploaded = await uploadVideoService.uploadMetadata(
        title: title,
        description: description,
        visibility: visibility,
        s3key: videoData['video_id'],
      );

      if (!isMetadataUploaded) {
        emit(const UploadVideoError("Metadata upload failed"));
        return;
      }

      emit(UploadVideoSuccess());
    } catch (e) {
      emit(UploadVideoError(e.toString()));
    }
  }
}
