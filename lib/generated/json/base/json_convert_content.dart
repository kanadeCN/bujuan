// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
import 'package:flutter/material.dart';
import 'package:bujuan/common/bean/lyric_content_entity.dart';
import 'package:bujuan/common/bean/lyric_entity.dart';
import 'package:bujuan/common/bean/lyric_hash_entity.dart';
import 'package:bujuan/common/bean/lyric_key_entity.dart';
import 'package:bujuan/common/bean/personalized_entity.dart';
import 'package:bujuan/common/bean/playlist_entity.dart';
import 'package:bujuan/common/bean/song_details_entity.dart';
import 'package:bujuan/common/bean/song_url_entity.dart';

JsonConvert jsonConvert = JsonConvert();
typedef JsonConvertFunction<T> = T Function(Map<String, dynamic> json);

class JsonConvert {
	static final Map<String, JsonConvertFunction> _convertFuncMap = {
		(LyricContentEntity).toString(): LyricContentEntity.fromJson,
		(LyricEntity).toString(): LyricEntity.fromJson,
		(LyricLrc).toString(): LyricLrc.fromJson,
		(LyricKlyric).toString(): LyricKlyric.fromJson,
		(LyricTlyric).toString(): LyricTlyric.fromJson,
		(LyricHashEntity).toString(): LyricHashEntity.fromJson,
		(LyricHashData).toString(): LyricHashData.fromJson,
		(LyricHashDataInfo).toString(): LyricHashDataInfo.fromJson,
		(LyricHashDataInfoTransParam).toString(): LyricHashDataInfoTransParam.fromJson,
		(LyricHashDataInfoTransParamClassmap).toString(): LyricHashDataInfoTransParamClassmap.fromJson,
		(LyricHashDataInfoTransParamHashOffset).toString(): LyricHashDataInfoTransParamHashOffset.fromJson,
		(LyricKeyEntity).toString(): LyricKeyEntity.fromJson,
		(LyricKeyCandidates).toString(): LyricKeyCandidates.fromJson,
		(LyricKeyCandidatesParinfoExt).toString(): LyricKeyCandidatesParinfoExt.fromJson,
		(PersonalizedEntity).toString(): PersonalizedEntity.fromJson,
		(PersonalizedResult).toString(): PersonalizedResult.fromJson,
		(PlaylistEntity).toString(): PlaylistEntity.fromJson,
		(PlaylistPlaylist).toString(): PlaylistPlaylist.fromJson,
		(PlaylistPlaylistSubscribers).toString(): PlaylistPlaylistSubscribers.fromJson,
		(PlaylistPlaylistCreator).toString(): PlaylistPlaylistCreator.fromJson,
		(PlaylistPlaylistCreatorAvatarDetail).toString(): PlaylistPlaylistCreatorAvatarDetail.fromJson,
		(PlaylistPlaylistTracks).toString(): PlaylistPlaylistTracks.fromJson,
		(PlaylistPlaylistTracksAr).toString(): PlaylistPlaylistTracksAr.fromJson,
		(PlaylistPlaylistTracksAl).toString(): PlaylistPlaylistTracksAl.fromJson,
		(PlaylistPlaylistTracksH).toString(): PlaylistPlaylistTracksH.fromJson,
		(PlaylistPlaylistTracksM).toString(): PlaylistPlaylistTracksM.fromJson,
		(PlaylistPlaylistTracksL).toString(): PlaylistPlaylistTracksL.fromJson,
		(PlaylistPlaylistTracksSq).toString(): PlaylistPlaylistTracksSq.fromJson,
		(PlaylistPlaylistTrackIds).toString(): PlaylistPlaylistTrackIds.fromJson,
		(PlaylistPrivileges).toString(): PlaylistPrivileges.fromJson,
		(PlaylistPrivilegesFreeTrialPrivilege).toString(): PlaylistPrivilegesFreeTrialPrivilege.fromJson,
		(PlaylistPrivilegesChargeInfoList).toString(): PlaylistPrivilegesChargeInfoList.fromJson,
		(SongDetailsEntity).toString(): SongDetailsEntity.fromJson,
		(SongDetailsSongs).toString(): SongDetailsSongs.fromJson,
		(SongDetailsSongsAr).toString(): SongDetailsSongsAr.fromJson,
		(SongDetailsSongsAl).toString(): SongDetailsSongsAl.fromJson,
		(SongDetailsSongsH).toString(): SongDetailsSongsH.fromJson,
		(SongDetailsSongsM).toString(): SongDetailsSongsM.fromJson,
		(SongDetailsSongsL).toString(): SongDetailsSongsL.fromJson,
		(SongDetailsSongsSq).toString(): SongDetailsSongsSq.fromJson,
		(SongDetailsSongsHr).toString(): SongDetailsSongsHr.fromJson,
		(SongDetailsSongsOriginSongSimpleData).toString(): SongDetailsSongsOriginSongSimpleData.fromJson,
		(SongDetailsSongsOriginSongSimpleDataArtists).toString(): SongDetailsSongsOriginSongSimpleDataArtists.fromJson,
		(SongDetailsSongsOriginSongSimpleDataAlbumMeta).toString(): SongDetailsSongsOriginSongSimpleDataAlbumMeta.fromJson,
		(SongDetailsSongsNoCopyrightRcmd).toString(): SongDetailsSongsNoCopyrightRcmd.fromJson,
		(SongUrlEntity).toString(): SongUrlEntity.fromJson,
		(SongUrlData).toString(): SongUrlData.fromJson,
		(SongUrlDataFreeTrialInfo).toString(): SongUrlDataFreeTrialInfo.fromJson,
		(SongUrlDataFreeTrialPrivilege).toString(): SongUrlDataFreeTrialPrivilege.fromJson,
		(SongUrlDataFreeTimeTrialPrivilege).toString(): SongUrlDataFreeTimeTrialPrivilege.fromJson,
	};

  T? convert<T>(dynamic value) {
    if (value == null) {
      return null;
    }
    return asT<T>(value);
  }

  List<T?>? convertList<T>(List<dynamic>? value) {
    if (value == null) {
      return null;
    }
    try {
      return value.map((dynamic e) => asT<T>(e)).toList();
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return <T>[];
    }
  }

  List<T>? convertListNotNull<T>(dynamic value) {
    if (value == null) {
      return null;
    }
    try {
      return (value as List<dynamic>).map((dynamic e) => asT<T>(e)!).toList();
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return <T>[];
    }
  }

  T? asT<T extends Object?>(dynamic value) {
    if (value is T) {
      return value;
    }
    final String type = T.toString();
    try {
      final String valueS = value.toString();
      if (type == "String") {
        return valueS as T;
      } else if (type == "int") {
        final int? intValue = int.tryParse(valueS);
        if (intValue == null) {
          return double.tryParse(valueS)?.toInt() as T?;
        } else {
          return intValue as T;
        }
      } else if (type == "double") {
        return double.parse(valueS) as T;
      } else if (type == "DateTime") {
        return DateTime.parse(valueS) as T;
      } else if (type == "bool") {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return (valueS == 'true') as T;
      } else if (type == "Map" || type.startsWith("Map<")) {
        return value as T;
      } else {
        if (_convertFuncMap.containsKey(type)) {
          return _convertFuncMap[type]!(value) as T;
        } else {
          throw UnimplementedError('$type unimplemented');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return null;
    }
  }

	//list is returned by type
	static M? _getListChildType<M>(List<Map<String, dynamic>> data) {
		if(<LyricContentEntity>[] is M){
			return data.map<LyricContentEntity>((Map<String, dynamic> e) => LyricContentEntity.fromJson(e)).toList() as M;
		}
		if(<LyricEntity>[] is M){
			return data.map<LyricEntity>((Map<String, dynamic> e) => LyricEntity.fromJson(e)).toList() as M;
		}
		if(<LyricLrc>[] is M){
			return data.map<LyricLrc>((Map<String, dynamic> e) => LyricLrc.fromJson(e)).toList() as M;
		}
		if(<LyricKlyric>[] is M){
			return data.map<LyricKlyric>((Map<String, dynamic> e) => LyricKlyric.fromJson(e)).toList() as M;
		}
		if(<LyricTlyric>[] is M){
			return data.map<LyricTlyric>((Map<String, dynamic> e) => LyricTlyric.fromJson(e)).toList() as M;
		}
		if(<LyricHashEntity>[] is M){
			return data.map<LyricHashEntity>((Map<String, dynamic> e) => LyricHashEntity.fromJson(e)).toList() as M;
		}
		if(<LyricHashData>[] is M){
			return data.map<LyricHashData>((Map<String, dynamic> e) => LyricHashData.fromJson(e)).toList() as M;
		}
		if(<LyricHashDataInfo>[] is M){
			return data.map<LyricHashDataInfo>((Map<String, dynamic> e) => LyricHashDataInfo.fromJson(e)).toList() as M;
		}
		if(<LyricHashDataInfoTransParam>[] is M){
			return data.map<LyricHashDataInfoTransParam>((Map<String, dynamic> e) => LyricHashDataInfoTransParam.fromJson(e)).toList() as M;
		}
		if(<LyricHashDataInfoTransParamClassmap>[] is M){
			return data.map<LyricHashDataInfoTransParamClassmap>((Map<String, dynamic> e) => LyricHashDataInfoTransParamClassmap.fromJson(e)).toList() as M;
		}
		if(<LyricHashDataInfoTransParamHashOffset>[] is M){
			return data.map<LyricHashDataInfoTransParamHashOffset>((Map<String, dynamic> e) => LyricHashDataInfoTransParamHashOffset.fromJson(e)).toList() as M;
		}
		if(<LyricKeyEntity>[] is M){
			return data.map<LyricKeyEntity>((Map<String, dynamic> e) => LyricKeyEntity.fromJson(e)).toList() as M;
		}
		if(<LyricKeyCandidates>[] is M){
			return data.map<LyricKeyCandidates>((Map<String, dynamic> e) => LyricKeyCandidates.fromJson(e)).toList() as M;
		}
		if(<LyricKeyCandidatesParinfoExt>[] is M){
			return data.map<LyricKeyCandidatesParinfoExt>((Map<String, dynamic> e) => LyricKeyCandidatesParinfoExt.fromJson(e)).toList() as M;
		}
		if(<PersonalizedEntity>[] is M){
			return data.map<PersonalizedEntity>((Map<String, dynamic> e) => PersonalizedEntity.fromJson(e)).toList() as M;
		}
		if(<PersonalizedResult>[] is M){
			return data.map<PersonalizedResult>((Map<String, dynamic> e) => PersonalizedResult.fromJson(e)).toList() as M;
		}
		if(<PlaylistEntity>[] is M){
			return data.map<PlaylistEntity>((Map<String, dynamic> e) => PlaylistEntity.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylist>[] is M){
			return data.map<PlaylistPlaylist>((Map<String, dynamic> e) => PlaylistPlaylist.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistSubscribers>[] is M){
			return data.map<PlaylistPlaylistSubscribers>((Map<String, dynamic> e) => PlaylistPlaylistSubscribers.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistCreator>[] is M){
			return data.map<PlaylistPlaylistCreator>((Map<String, dynamic> e) => PlaylistPlaylistCreator.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistCreatorAvatarDetail>[] is M){
			return data.map<PlaylistPlaylistCreatorAvatarDetail>((Map<String, dynamic> e) => PlaylistPlaylistCreatorAvatarDetail.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracks>[] is M){
			return data.map<PlaylistPlaylistTracks>((Map<String, dynamic> e) => PlaylistPlaylistTracks.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracksAr>[] is M){
			return data.map<PlaylistPlaylistTracksAr>((Map<String, dynamic> e) => PlaylistPlaylistTracksAr.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracksAl>[] is M){
			return data.map<PlaylistPlaylistTracksAl>((Map<String, dynamic> e) => PlaylistPlaylistTracksAl.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracksH>[] is M){
			return data.map<PlaylistPlaylistTracksH>((Map<String, dynamic> e) => PlaylistPlaylistTracksH.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracksM>[] is M){
			return data.map<PlaylistPlaylistTracksM>((Map<String, dynamic> e) => PlaylistPlaylistTracksM.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracksL>[] is M){
			return data.map<PlaylistPlaylistTracksL>((Map<String, dynamic> e) => PlaylistPlaylistTracksL.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTracksSq>[] is M){
			return data.map<PlaylistPlaylistTracksSq>((Map<String, dynamic> e) => PlaylistPlaylistTracksSq.fromJson(e)).toList() as M;
		}
		if(<PlaylistPlaylistTrackIds>[] is M){
			return data.map<PlaylistPlaylistTrackIds>((Map<String, dynamic> e) => PlaylistPlaylistTrackIds.fromJson(e)).toList() as M;
		}
		if(<PlaylistPrivileges>[] is M){
			return data.map<PlaylistPrivileges>((Map<String, dynamic> e) => PlaylistPrivileges.fromJson(e)).toList() as M;
		}
		if(<PlaylistPrivilegesFreeTrialPrivilege>[] is M){
			return data.map<PlaylistPrivilegesFreeTrialPrivilege>((Map<String, dynamic> e) => PlaylistPrivilegesFreeTrialPrivilege.fromJson(e)).toList() as M;
		}
		if(<PlaylistPrivilegesChargeInfoList>[] is M){
			return data.map<PlaylistPrivilegesChargeInfoList>((Map<String, dynamic> e) => PlaylistPrivilegesChargeInfoList.fromJson(e)).toList() as M;
		}
		if(<SongDetailsEntity>[] is M){
			return data.map<SongDetailsEntity>((Map<String, dynamic> e) => SongDetailsEntity.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongs>[] is M){
			return data.map<SongDetailsSongs>((Map<String, dynamic> e) => SongDetailsSongs.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsAr>[] is M){
			return data.map<SongDetailsSongsAr>((Map<String, dynamic> e) => SongDetailsSongsAr.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsAl>[] is M){
			return data.map<SongDetailsSongsAl>((Map<String, dynamic> e) => SongDetailsSongsAl.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsH>[] is M){
			return data.map<SongDetailsSongsH>((Map<String, dynamic> e) => SongDetailsSongsH.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsM>[] is M){
			return data.map<SongDetailsSongsM>((Map<String, dynamic> e) => SongDetailsSongsM.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsL>[] is M){
			return data.map<SongDetailsSongsL>((Map<String, dynamic> e) => SongDetailsSongsL.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsSq>[] is M){
			return data.map<SongDetailsSongsSq>((Map<String, dynamic> e) => SongDetailsSongsSq.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsHr>[] is M){
			return data.map<SongDetailsSongsHr>((Map<String, dynamic> e) => SongDetailsSongsHr.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsOriginSongSimpleData>[] is M){
			return data.map<SongDetailsSongsOriginSongSimpleData>((Map<String, dynamic> e) => SongDetailsSongsOriginSongSimpleData.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsOriginSongSimpleDataArtists>[] is M){
			return data.map<SongDetailsSongsOriginSongSimpleDataArtists>((Map<String, dynamic> e) => SongDetailsSongsOriginSongSimpleDataArtists.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsOriginSongSimpleDataAlbumMeta>[] is M){
			return data.map<SongDetailsSongsOriginSongSimpleDataAlbumMeta>((Map<String, dynamic> e) => SongDetailsSongsOriginSongSimpleDataAlbumMeta.fromJson(e)).toList() as M;
		}
		if(<SongDetailsSongsNoCopyrightRcmd>[] is M){
			return data.map<SongDetailsSongsNoCopyrightRcmd>((Map<String, dynamic> e) => SongDetailsSongsNoCopyrightRcmd.fromJson(e)).toList() as M;
		}
		if(<SongUrlEntity>[] is M){
			return data.map<SongUrlEntity>((Map<String, dynamic> e) => SongUrlEntity.fromJson(e)).toList() as M;
		}
		if(<SongUrlData>[] is M){
			return data.map<SongUrlData>((Map<String, dynamic> e) => SongUrlData.fromJson(e)).toList() as M;
		}
		if(<SongUrlDataFreeTrialInfo>[] is M){
			return data.map<SongUrlDataFreeTrialInfo>((Map<String, dynamic> e) => SongUrlDataFreeTrialInfo.fromJson(e)).toList() as M;
		}
		if(<SongUrlDataFreeTrialPrivilege>[] is M){
			return data.map<SongUrlDataFreeTrialPrivilege>((Map<String, dynamic> e) => SongUrlDataFreeTrialPrivilege.fromJson(e)).toList() as M;
		}
		if(<SongUrlDataFreeTimeTrialPrivilege>[] is M){
			return data.map<SongUrlDataFreeTimeTrialPrivilege>((Map<String, dynamic> e) => SongUrlDataFreeTimeTrialPrivilege.fromJson(e)).toList() as M;
		}

		debugPrint("${M.toString()} not found");
	
		return null;
}

	static M? fromJsonAsT<M>(dynamic json) {
		if (json is List) {
			return _getListChildType<M>(json.map((e) => e as Map<String, dynamic>).toList());
		} else {
			return jsonConvert.asT<M>(json);
		}
	}
}