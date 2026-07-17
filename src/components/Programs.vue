<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'
import { useAuth } from '../composables/useAuth'

const programs = ref([])
const loading = ref(true)
const errorMsg = ref('')
const router = useRouter()
const { isLoggedIn } = useAuth()

const gradients = [
  'from-forest to-leaf',
  'from-leaf to-emerald-400',
  'from-emerald-500 to-teal-400',
  'from-teal-500 to-cyan-400'
]

async function fetchPrograms() {
  loading.value = true
  errorMsg.value = ''
  // programs_preview adalah VIEW publik (tanpa kolom konten lengkap) supaya
  // ringkasan program bisa dilihat semua orang, sementara detail lengkap
  // hanya untuk member yang sudah login (lihat supabase/schema.sql).
  const { data, error } = await supabase
    .from('programs_preview')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    errorMsg.value = 'Gagal memuat program. Pastikan konfigurasi Supabase sudah benar.'
    console.error(error)
  } else {
    programs.value = data || []
  }
  loading.value = false
}

function openProgram(slug) {
  if (!isLoggedIn.value) {
    router.push({ name: 'login', query: { redirect: `/program/${slug}` } })
    return
  }
  router.push(`/program/${slug}`)
}

onMounted(fetchPrograms)
</script>

<template>
  <section id="programs" class="py-24 bg-cream scroll-mt-20">
    <div class="max-w-7xl mx-auto px-6">
      <div class="text-center mb-16">
        <p class="text-leaf font-semibold tracking-widest uppercase text-sm mb-3">Apa yang Kami Lakukan</p>
        <h2 class="font-display text-3xl md:text-5xl font-bold text-forest">Program Kami</h2>
        <p v-if="!isLoggedIn" class="text-gray-400 text-sm mt-4">Daftar sebagai member gratis untuk membaca detail lengkap tiap program.</p>
      </div>

      <div v-if="loading" class="text-center text-gray-400 py-12">Memuat program...</div>
      <div v-else-if="errorMsg" class="text-center text-red-500 py-12">{{ errorMsg }}</div>
      <div v-else-if="programs.length === 0" class="text-center text-gray-400 py-12">Belum ada program yang dipublikasikan.</div>

      <div v-else class="grid md:grid-cols-2 gap-8">
        <button
          v-for="(p, i) in programs"
          :key="p.id"
          @click="openProgram(p.slug)"
          class="card-hover text-left bg-white rounded-3xl overflow-hidden shadow-sm border border-green-50"
        >
          <div
            class="h-48 flex items-center justify-center bg-gradient-to-br"
            :class="gradients[i % gradients.length]"
          >
            <img v-if="p.image_url" :src="p.image_url" :style="{ objectPosition: p.image_position || '50% 50%' }" class="w-full h-full object-cover" alt="" />
            <img v-else src="/images/Programs.png" class="w-16 h-16 object-contain opacity-90" alt="" />
          </div>
          <div class="p-8">
            <p v-if="p.category" class="text-xs uppercase tracking-wider text-leaf font-semibold mb-2">{{ p.category }}</p>
            <h3 class="font-display font-bold text-xl text-forest mb-2">{{ p.title }}</h3>
            <p class="text-gray-500 text-sm leading-relaxed mb-4">{{ p.summary }}</p>
            <span class="text-leaf font-semibold text-sm flex items-center gap-1">
              {{ isLoggedIn ? 'Pelajari lebih lanjut' : 'Masuk untuk baca selengkapnya' }} →
            </span>
          </div>
        </button>
      </div>
    </div>
  </section>
</template>