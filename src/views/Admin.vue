<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuth } from '../composables/useAuth'

const { profile } = useAuth()

const programs = ref([])
const loading = ref(true)
const errorMsg = ref('')
const saving = ref(false)

const showForm = ref(false)
const editingId = ref(null)
const formSectionRef = ref(null)

const emptyForm = {
  title: '',
  slug: '',
  category: '',
  summary: '',
  content: '',
  image_url: ''
}
const form = ref({ ...emptyForm })

function slugify(text) {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
}

function onTitleInput() {
  // Auto-generate slug hanya saat membuat program baru (bukan saat edit)
  if (!editingId.value) {
    form.value.slug = slugify(form.value.title)
  }
}

async function fetchPrograms() {
  loading.value = true
  errorMsg.value = ''
  const { data, error } = await supabase
    .from('programs')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    errorMsg.value = 'Gagal memuat data: ' + error.message
  } else {
    programs.value = data || []
  }
  loading.value = false
}

async function scrollToForm() {
  // Tunggu form selesai dirender dulu (v-if), baru scroll ke posisinya.
  await nextTick()
  formSectionRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

function openCreateForm() {
  form.value = { ...emptyForm }
  editingId.value = null
  showForm.value = true
  scrollToForm()
}

function openEditForm(p) {
  form.value = {
    title: p.title,
    slug: p.slug,
    category: p.category || '',
    summary: p.summary || '',
    content: p.content || '',
    image_url: p.image_url || ''
  }
  editingId.value = p.id
  showForm.value = true
  scrollToForm()
}

function closeForm() {
  showForm.value = false
  editingId.value = null
}

async function handleSubmit() {
  saving.value = true
  errorMsg.value = ''
  try {
    if (editingId.value) {
      const { error } = await supabase
        .from('programs')
        .update({ ...form.value, updated_at: new Date().toISOString() })
        .eq('id', editingId.value)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('programs')
        .insert({ ...form.value })
      if (error) throw error
    }
    closeForm()
    await fetchPrograms()
  } catch (err) {
    errorMsg.value = 'Gagal menyimpan: ' + err.message
  } finally {
    saving.value = false
  }
}

async function handleDelete(p) {
  if (!confirm(`Hapus program "${p.title}"? Tindakan ini tidak bisa dibatalkan.`)) return
  const { error } = await supabase.from('programs').delete().eq('id', p.id)
  if (error) {
    errorMsg.value = 'Gagal menghapus: ' + error.message
  } else {
    await fetchPrograms()
  }
}

onMounted(fetchPrograms)
</script>

<template>
  <section class="pt-28 pb-24 px-6 bg-cream min-h-[80vh]">
    <div class="max-w-5xl mx-auto">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <p class="text-leaf font-semibold tracking-widest uppercase text-sm mb-1">Panel Admin</p>
          <h1 class="font-display font-bold text-3xl text-forest">Kelola Program &amp; Artikel</h1>
          <p class="text-gray-400 text-sm mt-1">Masuk sebagai {{ profile?.full_name || 'Admin' }}</p>
        </div>
        <button @click="openCreateForm" class="bg-forest text-white px-6 py-3 rounded-full font-semibold hover:bg-leaf transition-all whitespace-nowrap">
          + Tambah Program
        </button>
      </div>

      <p v-if="errorMsg" class="text-red-500 text-sm mb-4 bg-red-50 border border-red-100 rounded-xl p-3">{{ errorMsg }}</p>

      <!-- Form tambah/edit -->
      <div v-if="showForm" ref="formSectionRef" class="scroll-mt-24 bg-white rounded-3xl shadow-sm border border-green-50 p-6 md:p-8 mb-8">
        <h2 class="font-display font-bold text-xl text-forest mb-6">{{ editingId ? 'Edit Program' : 'Tambah Program Baru' }}</h2>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <label class="text-sm font-medium text-gray-700 block mb-1">Judul Program</label>
              <input v-model="form.title" @input="onTitleInput" type="text" required placeholder="Program Beasiswa"
                class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
            </div>
            <div>
              <label class="text-sm font-medium text-gray-700 block mb-1">Slug (URL)</label>
              <input v-model="form.slug" type="text" required placeholder="program-beasiswa"
                class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
            </div>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <label class="text-sm font-medium text-gray-700 block mb-1">Kategori</label>
              <input v-model="form.category" type="text" placeholder="Pendidikan"
                class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
            </div>
            <div>
              <label class="text-sm font-medium text-gray-700 block mb-1">URL Gambar (opsional)</label>
              <input v-model="form.image_url" type="url" placeholder="https://..."
                class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
            </div>
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Ringkasan (tampil di halaman publik)</label>
            <textarea v-model="form.summary" required rows="2" placeholder="Ringkasan singkat program..."
              class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition"></textarea>
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Konten Lengkap (hanya untuk member login)</label>
            <textarea v-model="form.content" required rows="6" placeholder="Detail lengkap program..."
              class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition"></textarea>
          </div>

          <div class="flex gap-3 pt-2">
            <button type="submit" :disabled="saving"
              class="bg-forest text-white px-6 py-3 rounded-xl font-semibold hover:bg-leaf transition-all disabled:opacity-60">
              {{ saving ? 'Menyimpan...' : (editingId ? 'Simpan Perubahan' : 'Publikasikan') }}
            </button>
            <button type="button" @click="closeForm" class="bg-gray-100 text-gray-600 px-6 py-3 rounded-xl font-semibold hover:bg-gray-200 transition-all">
              Batal
            </button>
          </div>
        </form>
      </div>

      <!-- Daftar program -->
      <div v-if="loading" class="text-center text-gray-400 py-16">Memuat data...</div>
      <div v-else-if="programs.length === 0" class="text-center text-gray-400 py-16">Belum ada program. Klik "Tambah Program" untuk membuat yang pertama.</div>

      <div v-else class="space-y-4">
        <div v-for="p in programs" :key="p.id" class="bg-white rounded-2xl border border-green-50 p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div class="min-w-0">
            <p v-if="p.category" class="text-xs uppercase tracking-wider text-leaf font-semibold mb-1">{{ p.category }}</p>
            <h3 class="font-display font-bold text-lg text-forest truncate">{{ p.title }}</h3>
            <p class="text-gray-500 text-sm truncate max-w-xl">{{ p.summary }}</p>
            <p class="text-gray-300 text-xs mt-1">/program/{{ p.slug }}</p>
          </div>
          <div class="flex gap-2 shrink-0">
            <button @click="openEditForm(p)" class="bg-mint text-forest px-4 py-2 rounded-full text-sm font-semibold hover:bg-forest hover:text-white transition-all">Edit</button>
            <button @click="handleDelete(p)" class="bg-red-50 text-red-500 px-4 py-2 rounded-full text-sm font-semibold hover:bg-red-500 hover:text-white transition-all">Hapus</button>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>