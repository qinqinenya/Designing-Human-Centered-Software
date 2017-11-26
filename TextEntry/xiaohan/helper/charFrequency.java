import java.io.*;
import java.util.*;

public class charFrequency {
    public static void main(String[] args) throws Exception {
        String fileName = "phrases2.txt";
        FileReader fr = null;
        BufferedReader br = null;

        int[] map = new int[26];
        PriorityQueue<entry> queue = new PriorityQueue<>((e1, e2) -> e2.freq - e1.freq);

        try {
            fr = new FileReader(fileName);
            br = new BufferedReader(fr);

            String line = null;
            while ((line = br.readLine()) != null) {
                for (char c: line.toCharArray()) {
                    if (c != ' ') {
                        map[c - 'a']++;
                    }
                }
            }

            for (int i = 0; i < 26; i++) {
                queue.offer(new entry((char)(i + 'a'), map[i]));
            }

            while (!queue.isEmpty()) {
                entry e = queue.poll();
                System.out.println(e.value + " " + e.freq);
            }
        } catch (FileNotFoundException e) {
            System.err.println(e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null) {
                br.close();
            }
            if (fr != null) {
                fr.close();
            }
        }
    }

    private static class entry {
        char value;
        int freq;
        entry(char value, int freq) {
            this.value = value;
            this.freq = freq;
        }
    }
}
