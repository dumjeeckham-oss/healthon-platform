import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js";

serve(async () => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 1. 오늘 step 데이터 가져오기
  const { data: steps } = await supabase
    .from("step_daily")
    .select("user_id, steps")
    .eq("date", new Date().toISOString().split("T")[0]);

  if (!steps) return new Response("no data");

  // 2. user별 합산
  const scoreMap: Record<string, number> = {};

  for (const row of steps) {
    scoreMap[row.user_id] = (scoreMap[row.user_id] || 0) + row.steps;
  }

  // 3. 정렬
  const ranking = Object.entries(scoreMap)
    .sort((a, b) => b[1] - a[1])
    .map(([user_id, steps], index) => ({
      user_id,
      score: steps,
      rank: index + 1,
    }));

  // 4. 기존 랭킹 초기화
  await supabase.from("rankings").delete().neq("id", "");

  // 5. 새 랭킹 저장
  for (const r of ranking) {
    await supabase.from("rankings").insert({
      user_id: r.user_id,
      score: r.score,
      rank: r.rank,
      updated_at: new Date().toISOString(),
    });
  }

  return new Response("ranking updated");
});