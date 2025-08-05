import 'package:just_audio/just_audio.dart';
import 'package:musicvoxaplay/screens/models/song_models.dart';
import 'package:musicvoxaplay/screens/services/song_service.dart';

class PlayNextService {
  final SongService songService;
  final AudioPlayer audioPlayer;

  PlayNextService({required this.songService, required this.audioPlayer});

  Future<Song?> playNext(Song currentSong) async {
    try {

      List<Song> songs = await songService.fetchSongsFromDevice();
      if (songs.isEmpty) {
        print('No songs available to play next');
        return null;
      }


      int currentIndex = songs.indexWhere((song) => song.path == currentSong.path);
      if (currentIndex == -1) {
        print('Current song not found in the song list');
        return null;
      }


      int nextIndex = (currentIndex + 1) % songs.length;
      Song nextSong = songs[nextIndex];


      await audioPlayer.setFilePath(nextSong.path);
      await audioPlayer.play();

      await songService.incrementPlayCount(nextSong);
      print('Playing next song: "${nextSong.title}"');
      return nextSong; 
    } catch (e) {
      print('Error playing next song: $e');
      return null;
    }
  }
}