<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

const news = ref([])
const loading = ref(true)
const errorMsg = ref('')

async function fetchNews() {
  loading.value = true
  errorMsg.value = ''
  const { data, error } = await supabase
    .from('news')
    .select('id, title, slug, category, summary, image_url, image_position, created_at')
    .order('created_at', { ascending: false })

  if (error) {
    errorMsg.value = 'Gagal memuat berita.'
    console.error(error)
  } else {
    news.value = data || []
  }
  loading.value = false
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}

onMounted(fetchNews)
</script>

<template>
  <section class="pt-32 pb-24 px-6 bg-cream min-h-[80vh]">
    <div class="max-w-5xl mx-auto">
      <div class="text-center mb-16">
        <p class="text-leaf font-semibold tracking-widest uppercase text-sm mb-3">Kabar Terbaru</p>
        <h1 class="font-display text-3xl md:text-5xl font-bold text-forest">Berita &amp; Kegiatan</h1>
      </div>

      <div v-if="loading" class="text-center text-gray-400 py-16">Memuat berita...</div>
      <div v-else-if="errorMsg" class="text-center text-red-500 py-16">{{ errorMsg }}</div>
      <div v-else-if="news.length === 0" class="text-center text-gray-400 py-16">Belum ada berita yang dipublikasikan.</div>

      <div v-else class="grid md:grid-cols-2 gap-8">
        <router-link
          v-for="n in news"
          :key="n.id"
          :to="`/berita/${n.slug}`"
          class="card-hover block bg-white rounded-3xl overflow-hidden border border-green-50 shadow-sm"
        >
          <div class="h-48 bg-gradient-to-br from-forest to-leaf flex items-center justify-center">
            <img v-if="n.image_url" :src="n.image_url" :style="{ objectPosition: n.image_position || '50% 50%' }" class="w-full h-full object-cover" alt="" />
          </div>
          <div class="p-8">
            <p v-if="n.category" class="text-xs uppercase tracking-wider text-leaf font-semibold mb-2">{{ n.category }}</p>
            <p class="text-gray-400 text-xs mb-2">{{ formatDate(n.created_at) }}</p>
            <h3 class="font-display font-bold text-xl text-forest mb-2">{{ n.title }}</h3>
            <p class="text-gray-500 text-sm leading-relaxed">{{ n.summary }}</p>
          </div>
        </router-link>
      </div>
    </div>
  </section>
</template>