<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const route = useRoute()
const router = useRouter()
const program = ref(null)
const loading = ref(true)
const errorMsg = ref('')

async function fetchProgram(slug) {
  loading.value = true
  errorMsg.value = ''
  // Tabel penuh 'programs' hanya bisa dibaca oleh user yang sudah login (lihat RLS di schema.sql)
  const { data, error } = await supabase
    .from('programs')
    .select('*')
    .eq('slug', slug)
    .single()

  if (error) {
    errorMsg.value = 'Program tidak ditemukan atau kamu tidak punya akses.'
    console.error(error)
  } else {
    program.value = data
  }
  loading.value = false
}

onMounted(() => fetchProgram(route.params.slug))
watch(() => route.params.slug, (slug) => fetchProgram(slug))
</script>

<template>
  <section class="pt-32 pb-24 px-6 bg-cream min-h-[80vh]">
    <div class="max-w-3xl mx-auto">
      <button @click="router.back()" class="text-leaf text-sm font-semibold mb-6 flex items-center gap-1">← Kembali</button>

      <div v-if="loading" class="text-center text-gray-400 py-20">Memuat...</div>
      <div v-else-if="errorMsg" class="text-center text-red-500 py-20">{{ errorMsg }}</div>

      <article v-else-if="program" class="bg-white rounded-3xl shadow-sm border border-green-50 overflow-hidden">
        <div class="h-64 bg-gradient-to-br from-forest to-leaf flex items-center justify-center">
          <img v-if="program.image_url" :src="program.image_url" class="w-full h-full object-cover" alt="" />
          <img v-else src="/images/Programs.png" class="w-20 h-20 object-contain opacity-90" alt="" />
        </div>
        <div class="p-8 md:p-10">
          <p v-if="program.category" class="text-xs uppercase tracking-wider text-leaf font-semibold mb-3">{{ program.category }}</p>
          <h1 class="font-display font-bold text-3xl md:text-4xl text-forest mb-4">{{ program.title }}</h1>
          <p class="text-gray-500 text-lg mb-8">{{ program.summary }}</p>
          <div class="prose max-w-none text-gray-700 whitespace-pre-line leading-relaxed">{{ program.content }}</div>
        </div>
      </article>
    </div>
  </section>
</template>