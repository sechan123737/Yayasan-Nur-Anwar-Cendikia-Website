<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const route = useRoute()
const router = useRouter()
const article = ref(null)
const loading = ref(true)
const errorMsg = ref('')

async function fetchArticle(slug) {
  loading.value = true
  errorMsg.value = ''
  const { data, error } = await supabase
    .from('news')
    .select('*')
    .eq('slug', slug)
    .single()

  if (error) {
    errorMsg.value = 'Berita tidak ditemukan.'
    console.error(error)
  } else {
    article.value = data
  }
  loading.value = false
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}

onMounted(() => fetchArticle(route.params.slug))
watch(() => route.params.slug, (slug) => fetchArticle(slug))
</script>

<template>
  <section class="pt-32 pb-24 px-6 bg-cream min-h-[80vh]">
    <div class="max-w-3xl mx-auto">
      <button @click="router.back()" class="text-leaf text-sm font-semibold mb-6 flex items-center gap-1">← Kembali</button>

      <div v-if="loading" class="text-center text-gray-400 py-20">Memuat...</div>
      <div v-else-if="errorMsg" class="text-center text-red-500 py-20">{{ errorMsg }}</div>

      <article v-else-if="article" class="bg-white rounded-3xl shadow-sm border border-green-50 overflow-hidden">
        <div class="h-64 bg-gradient-to-br from-forest to-leaf flex items-center justify-center">
          <img v-if="article.image_url" :src="article.image_url" :style="{ objectPosition: article.image_position || '50% 50%' }" class="w-full h-full object-cover" alt="" />
        </div>
        <div class="p-8 md:p-10">
          <p v-if="article.category" class="text-xs uppercase tracking-wider text-leaf font-semibold mb-3">{{ article.category }}</p>
          <p class="text-gray-400 text-sm mb-3">{{ formatDate(article.created_at) }}</p>
          <h1 class="font-display font-bold text-3xl md:text-4xl text-forest mb-4">{{ article.title }}</h1>
          <p class="text-gray-500 text-lg mb-8">{{ article.summary }}</p>
          <div class="prose max-w-none text-gray-700 whitespace-pre-line leading-relaxed">{{ article.content }}</div>
        </div>
      </article>
    </div>
  </section>
</template>