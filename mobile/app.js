// mobile/App.js
import React, { useState, useEffect, useRef } from 'react';
import { SafeAreaView, View, Dimensions, FlatList, Text, TouchableOpacity } from 'react-native';
import { Video } from 'expo-av';

const { height } = Dimensions.get('window');

function VideoItem({ item, isActive }) {
  const ref = useRef(null);
  useEffect(() => {
    if (isActive) {
      ref.current?.playAsync();
    } else {
      ref.current?.pauseAsync();
    }
  }, [isActive]);

  return (
    <View style={{ height, justifyContent: 'center', alignItems: 'center' }}>
      <Video
        ref={ref}
        source={{ uri: item.url }}
        style={{ width: '100%', height: '100%' }}
        resizeMode="cover"
        isLooping
        shouldPlay={isActive}
      />
      <View style={{ position: 'absolute', bottom: 80, left: 16 }}>
        <Text style={{ color: 'white', fontSize: 18 }}>{item.title}</Text>
      </View>
    </View>
  );
}

export default function App() {
  const [data, setData] = useState([]);
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    // fetch initial feed from API
    setData([
      { id: '1', url: 'https://d25.../example1.mp4', title: 'Clip 1' },
      { id: '2', url: 'https://d25.../example2.mp4', title: 'Clip 2' }
    ]);
  }, []);

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: 'black' }}>
      <FlatList
        data={data}
        keyExtractor={(i) => i.id}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        onMomentumScrollEnd={(ev) => {
          const newIndex = Math.round(ev.nativeEvent.contentOffset.y / height);
          setActiveIndex(newIndex);
        }}
        renderItem={({ item, index }) => (
          <VideoItem item={item} isActive={index === activeIndex} />
        )}
      />
    </SafeAreaView>
  );
}
