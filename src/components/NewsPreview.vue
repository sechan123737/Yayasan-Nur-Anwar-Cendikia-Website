<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { supabase } from '../lib/supabase'

const news = ref([])
const loading = ref(true)
const currentIndex = ref(0)

let autoplayTimer = null
const AUTOPLAY_DELAY = 4500

async function fetchLatestNews() {
  loading.value = true
  const { data, error } = await supabase
    .from('news')
    .select('id, title, slug, category, summary, image_url, created_at')
    .order('created_at', { ascending: false })
    .limit(5)

  if (!error) news.value = data || []
  loading.value = false
  startAutoplay()
}

function goTo(index) {
  const total = news.value.length
  currentIndex.value = (index + total) % total
}
function next() { goTo(currentIndex.value + 1) }

function startAutoplay() {
  stopAutoplay()
  if (news.value.length <= 1) return
  autoplayTimer = setInterval(next, AUTOPLAY_DELAY)
}
function stopAutoplay() {
  if (autoplayTimer) clearInterval(autoplayTimer)
}
function restartAutoplay() {
  stopAutoplay()
  startAutoplay()
}

// --- Dukungan swipe manual (drag mouse / sentuh layar) ---
const trackRef = ref(null)
const isDragging = ref(false)
let startX = 0
let dragOffset = ref(0)

function onPointerDown(e) {
  isDragging.value = true
  startX = (e.touches ? e.touches[0].clientX : e.clientX)
  stopAutoplay()
}
function onPointerMove(e) {
  if (!isDragging.value) return
  const x = (e.touches ? e.touches[0].clientX : e.clientX)
  dragOffset.value = x - startX
}
function onPointerUp() {
  if (!isDragging.value) return
  isDragging.value = false
  const threshold = 60
  if (dragOffset.value > threshold) {
    goTo(currentIndex.value - 1)
  } else if (dragOffset.value < -threshold) {
    goTo(currentIndex.value + 1)
  }
  dragOffset.value = 0
  restartAutoplay()
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}

onMounted(fetchLatestNews)
onUnmounted(stopAutoplay)
</script>

<template>
  <section id="news" class="py-16 bg-white scroll-mt-20" v-if="loading || news.length > 0">
    <div class="max-w-7xl mx-auto px-6">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-12">
        <div>
          <p class="text-leaf font-semibold tracking-widest uppercase text-sm mb-3">Kabar Terbaru</p>
          <h2 class="font-display text-3xl md:text-5xl font-bold text-forest">Berita &amp; Kegiatan</h2>
        </div>
        <router-link to="/berita" class="text-leaf font-semibold text-sm hover:underline whitespace-nowrap">Lihat semua berita →</router-link>
      </div>

      <div v-if="loading" class="text-center text-gray-400 py-8">Memuat berita...</div>

      <div v-else class="relative select-none max-w-5xl mx-auto">
        <!-- Viewport: satu slide penuh berbentuk persegi panjang (landscape) -->
        <div
          class="overflow-hidden rounded-3xl cursor-grab active:cursor-grabbing"
          @mousedown="onPointerDown"
          @mousemove="onPointerMove"
          @mouseup="onPointerUp"
          @mouseleave="onPointerUp"
          @touchstart="onPointerDown"
          @touchmove="onPointerMove"
          @touchend="onPointerUp"
        >
          <div
            ref="trackRef"
            class="flex transition-transform ease-out"
            :class="isDragging ? 'duration-0' : 'duration-500'"
            :style="{ transform: `translateX(calc(-${currentIndex * 100}% + ${dragOffset}px))` }"
          >
            <router-link
              v-for="n in news"
              :key="n.id"
              :to="`/berita/${n.slug}`"
              class="w-full shrink-0 grid md:grid-cols-2 bg-cream border border-green-50 rounded-3xl overflow-hidden h-64 md:h-72"
              @click.capture="dragOffset !== 0 && $event.preventDefault()"
            >
              <div class="h-full bg-gradient-to-br from-forest to-leaf flex items-center justify-center order-2 md:order-1">
                <img v-if="n.image_url" :src="n.image_url" class="w-full h-full object-cover" alt="" draggable="false" />
              </div>
              <div class="p-5 md:p-6 flex flex-col justify-center order-1 md:order-2">
                <p v-if="n.category" class="text-xs uppercase tracking-wider text-leaf font-semibold mb-1">{{ n.category }}</p>
                <p class="text-gray-400 text-xs mb-2">{{ formatDate(n.created_at) }}</p>
                <h3 class="font-display font-bold text-lg md:text-xl text-forest mb-2 leading-snug">{{ n.title }}</h3>
                <p class="text-gray-500 text-sm leading-relaxed line-clamp-2">{{ n.summary }}</p>
            </div>
            </router-link>
          </div>
        </div>

        <!-- Tombol panah -->
        <button
          @click="goTo(currentIndex - 1); restartAutoplay()"
          class="hidden sm:flex absolute left-3 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-white/90 shadow-md items-center justify-center text-forest hover:bg-white transition-all"
          aria-label="Sebelumnya"
        >‹</button>
        <button
          @click="goTo(currentIndex + 1); restartAutoplay()"
          class="hidden sm:flex absolute right-3 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-white/90 shadow-md items-center justify-center text-forest hover:bg-white transition-all"
          aria-label="Berikutnya"
        >›</button>

        <!-- Dot indikator -->
        <div class="flex justify-center gap-2 mt-6">
          <button
            v-for="(n, i) in news"
            :key="n.id"
            @click="goTo(i); restartAutoplay()"
            class="h-2 rounded-full transition-all"
            :class="i === currentIndex ? 'w-6 bg-forest' : 'w-2 bg-gray-300 hover:bg-gray-400'"
            :aria-label="`Ke slide ${i + 1}`"
          />
        </div>
      </div>
    </div>
  </section>
</template>