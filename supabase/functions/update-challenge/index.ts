import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js";

serve(async () => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: progress } = await supabase
    .from("step_daily")
    .select("user_id, steps");

  for (const row of progress || []) {
    const km = row.steps * 0.0007;

    await supabase
      .from("challenge_progress")
      .upsert({
        user_id: row.user_id,
        current_km: km,
        percent: (km / 100) * 100,
        updated_at: new Date().toISOString(),
      });
  }

  return new Response("challenge updated");
});